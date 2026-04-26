import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.nio.file.*;
import java.util.List;
import javax.swing.*;

public class FileOverwriteUI extends JFrame {
    private JList<String> fileList;
    private DefaultListModel<String> listModel;
    private JButton overwriteButton;
    private JButton restoreButton;
    private JTextArea statusArea;
    private JLabel sourceLabel;
    private JLabel targetLabel;
    private File sourceDir;
    private File configDir;
    private DatabaseManager dbManager;

    public FileOverwriteUI() {
        setTitle("River WM Config Overwrite Tool");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(700, 550);
        setLocationRelativeTo(null);

        // Initialize directories
        sourceDir = new File(System.getProperty("user.home"), "riverwm");
        configDir = new File(System.getProperty("user.home"), ".config");
        dbManager = DatabaseManager.getInstance();

        // Main panel
        JPanel mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // Top: info panel
        JPanel infoPanel = new JPanel(new GridLayout(3, 1, 5, 5));
        JLabel titleLabel = new JLabel("Select River WM configs to overwrite in ~/.config/");
        titleLabel.setFont(new Font("Dialog", Font.BOLD, 14));
        sourceLabel = new JLabel("Source: " + sourceDir.getAbsolutePath());
        targetLabel = new JLabel("Target: " + configDir.getAbsolutePath());
        infoPanel.add(titleLabel);
        infoPanel.add(sourceLabel);
        infoPanel.add(targetLabel);
        mainPanel.add(infoPanel, BorderLayout.NORTH);

        // Center: file list with scroll
        listModel = new DefaultListModel<>();
        fileList = new JList<>(listModel);
        fileList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        fileList.setFont(new Font("Monospaced", Font.PLAIN, 12));
        loadFiles(); // Call after initializing listModel
        JScrollPane scrollPane = new JScrollPane(fileList);
        mainPanel.add(scrollPane, BorderLayout.CENTER);

        // Bottom: buttons and status
        JPanel bottomPanel = new JPanel(new BorderLayout(10, 10));

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 0));
        overwriteButton = new JButton("Overwrite Selected");
        restoreButton = new JButton("Restore");
        JButton refreshButton = new JButton("Refresh");
        JButton cancelButton = new JButton("Exit");

        overwriteButton.addActionListener(e -> overwriteFiles());
        restoreButton.addActionListener(e -> openRestoreDialog());
        refreshButton.addActionListener(e -> {
            listModel.clear();
            loadFiles();
            statusArea.setText("File list refreshed.");
        });
        cancelButton.addActionListener(e -> System.exit(0));

        buttonPanel.add(refreshButton);
        buttonPanel.add(restoreButton);
        buttonPanel.add(overwriteButton);
        buttonPanel.add(cancelButton);

        // Initialize statusArea
        statusArea = new JTextArea(5, 60);
        statusArea.setEditable(false);
        statusArea.setLineWrap(true);
        statusArea.setWrapStyleWord(true);
        statusArea.setFont(new Font("Monospaced", Font.PLAIN, 11));
        statusArea.setText("Ready. Select files/directories and click 'Overwrite Selected'.");

        JScrollPane statusScroll = new JScrollPane(statusArea);
        bottomPanel.add(buttonPanel, BorderLayout.NORTH);
        bottomPanel.add(new JLabel("Status:"), BorderLayout.WEST);
        bottomPanel.add(statusScroll, BorderLayout.CENTER);

        mainPanel.add(bottomPanel, BorderLayout.SOUTH);
        add(mainPanel);
    }

    private void loadFiles() {
        if (!sourceDir.exists() || !sourceDir.isDirectory()) {
            statusArea.setText("Error: " + sourceDir.getAbsolutePath() + " not found!");
            return;
        }

        File[] files = sourceDir.listFiles();
        if (files != null) {
            for (File file : files) {
                String displayName = file.getName();
                if (file.isDirectory()) {
                    displayName += "/";
                }
                listModel.addElement(displayName);
            }
        }
    }

    private String getTargetPath(String itemName) {
        return itemName;
    }

    private void overwriteFiles() {
        int[] selectedIndices = fileList.getSelectedIndices();
        if (selectedIndices.length == 0) {
            statusArea.setText("No files selected!");
            return;
        }

        StringBuilder result = new StringBuilder();
        int successCount = 0;
        int errorCount = 0;

        File fishDir = new File(configDir, "fish");
        File riverDir = new File(configDir, "river");
        fishDir.mkdirs();
        riverDir.mkdirs();
        result.append("Ensured ~/.config/fish/ and ~/.config/river/ exist\n\n");

        for (int index : selectedIndices) {
            String itemName = listModel.getElementAt(index).replace("/", "");
            File sourceFile = new File(sourceDir, itemName);
            String targetSubdir = getTargetPath(itemName);
            File targetFile = new File(configDir, targetSubdir);

            try {
                if (targetFile.exists()) {
                    dbManager.deleteOldBackups(itemName);
                    String backupPath = dbManager.saveBackup(itemName, targetFile.getAbsolutePath());
                    copyToBackup(targetFile, new File(backupPath));
                    result.append("Backed up: ").append(itemName).append(" -> ").append(backupPath).append("\n");
                }

                if (sourceFile.isDirectory()) {
                    targetFile.getParentFile().mkdirs();
                    if (targetFile.exists()) {
                        deleteDirectory(targetFile);
                    }
                    copyDirectory(sourceFile, targetFile);
                    result.append("Overwritten directory: ~/.config/").append(targetSubdir).append("/\n");
                    successCount++;
                } else {
                    targetFile.getParentFile().mkdirs();
                    Files.copy(sourceFile.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    result.append("Overwritten file: ~/.config/").append(targetSubdir).append("\n");
                    successCount++;
                }
            } catch (Exception ex) {
                result.append("Error with ").append(itemName).append(": ").append(ex.getMessage()).append("\n");
                errorCount++;
            }
        }

        result.append("\n--- Summary ---\n");
        result.append("Success: ").append(successCount).append(" | Errors: ").append(errorCount);
        statusArea.setText(result.toString());
    }

    private void copyToBackup(File source, File destination) throws IOException {
        if (source.isDirectory()) {
            copyDirectory(source, destination);
        } else {
            destination.getParentFile().mkdirs();
            Files.copy(source.toPath(), destination.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private void openRestoreDialog() {
        try {
            List<String> filenames = dbManager.getAllBackupFilenames();
            if (filenames.isEmpty()) {
                JOptionPane.showMessageDialog(this, "No backups found.", "Restore", JOptionPane.INFORMATION_MESSAGE);
                return;
            }

            String selectedFilename = (String) JOptionPane.showInputDialog(
                this,
                "Select a config to restore:",
                "Restore Backup",
                JOptionPane.QUESTION_MESSAGE,
                null,
                filenames.toArray(),
                filenames.get(0)
            );

            if (selectedFilename != null) {
                BackupHistoryDialog dialog = new BackupHistoryDialog(this, selectedFilename, dbManager);
                dialog.setVisible(true);
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error loading backups: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void copyDirectory(File source, File destination) throws IOException {
        if (!destination.exists()) {
            destination.mkdirs();
        }

        File[] files = source.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.getName().equals("backups")) {
                    continue;
                }
                File newFile = new File(destination, file.getName());
                if (file.isDirectory()) {
                    copyDirectory(file, newFile);
                } else {
                    Files.copy(file.toPath(), newFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }
        }
    }

    private void deleteDirectory(File directory) throws IOException {
        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory()) {
                    deleteDirectory(file);
                } else {
                    Files.deleteIfExists(file.toPath());
                }
            }
        }
        Files.delete(directory.toPath());
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            FileOverwriteUI frame = new FileOverwriteUI();
            frame.setVisible(true);
        });
    }
}
