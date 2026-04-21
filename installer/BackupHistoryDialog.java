import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.nio.file.*;
import java.util.List;
import javax.swing.*;
import javax.swing.table.DefaultTableModel;

public class BackupHistoryDialog extends JDialog {
    private JTable backupTable;
    private DefaultTableModel tableModel;
    private String filename;
    private DatabaseManager dbManager;
    private JFrame parentFrame;

    public BackupHistoryDialog(JFrame parent, String filename, DatabaseManager dbManager) {
        super(parent, "Restore: " + filename, true);
        this.parentFrame = parent;
        this.filename = filename;
        this.dbManager = dbManager;

        setSize(500, 350);
        setLocationRelativeTo(parent);
        setLayout(new BorderLayout(10, 10));

        JLabel titleLabel = new JLabel("Backup History: " + filename);
        titleLabel.setFont(new Font("Dialog", Font.BOLD, 14));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(10, 10, 0, 10));
        add(titleLabel, BorderLayout.NORTH);

        String[] columnNames = {"Version", "Date"};
        tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        backupTable = new JTable(tableModel);
        backupTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        backupTable.setFont(new Font("Monospaced", Font.PLAIN, 12));
        backupTable.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                if (e.getClickCount() == 2) {
                    restoreSelected();
                }
            }
        });

        JScrollPane scrollPane = new JScrollPane(backupTable);
        scrollPane.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        add(scrollPane, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT, 10, 10));
        JButton restoreButton = new JButton("Restore Selected");
        JButton cancelButton = new JButton("Cancel");

        restoreButton.addActionListener(e -> restoreSelected());
        cancelButton.addActionListener(e -> dispose());

        buttonPanel.add(restoreButton);
        buttonPanel.add(cancelButton);
        add(buttonPanel, BorderLayout.SOUTH);

        loadBackups();
    }

    private void loadBackups() {
        try {
            List<BackupInfo> backups = dbManager.getVersions(filename);
            for (BackupInfo backup : backups) {
                Object[] row = {
                    "v" + backup.getVersion(),
                    backup.getBackedUpAt()
                };
                tableModel.addRow(row);
            }

            if (backups.isEmpty()) {
                JOptionPane.showMessageDialog(this, "No backups found for " + filename, "Info", JOptionPane.INFORMATION_MESSAGE);
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error loading backups: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void restoreSelected() {
        int selectedRow = backupTable.getSelectedRow();
        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "Please select a backup to restore.", "No Selection", JOptionPane.WARNING_MESSAGE);
            return;
        }

        try {
            List<BackupInfo> backups = dbManager.getVersions(filename);
            BackupInfo selectedBackup = backups.get(selectedRow);

            int confirm = JOptionPane.showConfirmDialog(
                this,
                "Restore " + filename + " to version " + selectedBackup.getVersion() + "?\nThis will overwrite current config.",
                "Confirm Restore",
                JOptionPane.YES_NO_OPTION
            );

            if (confirm == JOptionPane.YES_OPTION) {
                File backupDir = new File(selectedBackup.getBackupPath());
                File targetDir = new File(System.getProperty("user.home"), ".config/" + getTargetPath(filename));

                if (targetDir.exists()) {
                    deleteDirectory(targetDir);
                }
                targetDir.getParentFile().mkdirs();
                copyDirectory(backupDir, targetDir);

                JOptionPane.showMessageDialog(this, "Successfully restored " + filename + " to v" + selectedBackup.getVersion(), "Success", JOptionPane.INFORMATION_MESSAGE);
                dispose();
            }
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Error restoring backup: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private String getTargetPath(String itemName) {
        if (itemName.equals("fish")) {
            return "fish";
        } else {
            return "river";
        }
    }

    private void copyDirectory(File source, File destination) throws IOException {
        if (!destination.exists()) {
            destination.mkdirs();
        }

        File[] files = source.listFiles();
        if (files != null) {
            for (File file : files) {
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
                    Files.delete(file.toPath());
                }
            }
        }
        Files.delete(directory.toPath());
    }
}
