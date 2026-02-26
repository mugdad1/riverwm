import javax.swing.*;
import javax.swing.table.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;
import java.util.List;

public class PackageInstallerApp extends JFrame {

    private JTextField searchField;
    private JTable pkgTable;
    private DefaultTableModel model;
    private JTextArea logArea;
    private JButton installSelectedBtn;
    private JButton uninstallSelectedBtn;

    private Set<String> installed = new HashSet<>();
    private javax.swing.Timer searchTimer;

    public PackageInstallerApp() {
        super("Void Linux Package Search & Installer");
        setSize(1000, 700);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        JPanel top = new JPanel(new BorderLayout());
        searchField = new JTextField();
        top.add(new JLabel("Search Packages:"), BorderLayout.WEST);
        top.add(searchField, BorderLayout.CENTER);

        installSelectedBtn = new JButton("Install Selected");
        uninstallSelectedBtn = new JButton("Uninstall Selected");
        JPanel btns = new JPanel();
        btns.add(installSelectedBtn);
        btns.add(uninstallSelectedBtn);
        top.add(btns, BorderLayout.EAST);
        add(top, BorderLayout.NORTH);

        model = new DefaultTableModel(new String[]{"Package", "Description", "Installed?", "Select"}, 0) {
            public Class<?> getColumnClass(int c) {
                return c == 3 ? Boolean.class : String.class;
            }
            public boolean isCellEditable(int r, int c) {
                return c == 3;
            }
        };
        pkgTable = new JTable(model);
        add(new JScrollPane(pkgTable), BorderLayout.CENTER);

        logArea = new JTextArea(10, 60);
        logArea.setEditable(false);
        add(new JScrollPane(logArea), BorderLayout.SOUTH);

        initListeners();
        refreshInstalled();

        setVisible(true);
    }

    private void initListeners() {
        searchTimer = new javax.swing.Timer(300, e -> performSearch());
        searchTimer.setRepeats(false);

        searchField.addKeyListener(new KeyAdapter() {
            public void keyReleased(KeyEvent e) {
                searchTimer.restart(); // delay search
            }
        });

        installSelectedBtn.addActionListener(e -> operateSelected(true));
        uninstallSelectedBtn.addActionListener(e -> operateSelected(false));
    }

    private void refreshInstalled() {
        installed.clear();
        try {
            Process p = new ProcessBuilder("xbps-query", "-l").start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.trim().split("\\s+");
                if (parts.length >= 2) {
                    installed.add(parts[1].split("-")[0]);
                }
            }
            p.waitFor();
        } catch (Exception ex) {
            log("Error reading installed packages: " + ex.getMessage());
        }
    }

    private void performSearch() {
        String query = searchField.getText().trim();
        if (query.isEmpty()) {
            model.setRowCount(0);
            return;
        }

        Map<String, Boolean> prev = new HashMap<>();
        for (int i = 0; i < model.getRowCount(); i++) {
            prev.put((String) model.getValueAt(i, 0), (Boolean) model.getValueAt(i, 3));
        }
        model.setRowCount(0);

        try {
            ProcessBuilder pb = new ProcessBuilder("xbps-query", "-R", "-s", query);
            pb.redirectErrorStream(true);
            Process p = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\s+", 3);
                if (parts.length >= 2) {
                    String nameVer = parts[1].trim();
                    String pkgName = nameVer.split("-")[0];
                    String desc = parts.length > 2 ? parts[2] : "";
                    boolean isInst = installed.contains(pkgName);
                    boolean wasChecked = prev.getOrDefault(pkgName, false);
                    model.addRow(new Object[]{pkgName, desc, isInst ? "Yes" : "No", wasChecked});
                }
            }
            p.waitFor();
        } catch (Exception ex) {
            log("Search error: " + ex.getMessage());
        }
    }

    private void operateSelected(boolean install) {
        List<String> selected = new ArrayList<>();
        for (int i = 0; i < model.getRowCount(); i++) {
            if (Boolean.TRUE.equals(model.getValueAt(i, 3))) {
                selected.add((String) model.getValueAt(i, 0));
            }
        }
        if (selected.isEmpty()) {
            JOptionPane.showMessageDialog(this, "No packages selected!");
            return;
        }
        runPackageAction(selected, install);
    }

    private void runPackageAction(List<String> packages, boolean install) {
        log((install ? "Installing " : "Removing ") + packages);
        new SwingWorker<Void, String>() {
            protected Void doInBackground() throws Exception {
                for (String pkg : packages) {
                    if (install && installed.contains(pkg)) {
                        publish(pkg + " already installed, skipping.");
                        continue;
                    }
                    if (!install && !installed.contains(pkg)) {
                        publish(pkg + " not installed, skipping.");
                        continue;
                    }
                    List<String> cmd = new ArrayList<>();
                    cmd.add("pkexec");
                    cmd.add("env");
                    cmd.add("DISPLAY=" + System.getenv("DISPLAY"));
                    cmd.add("_JAVA_AWT_WM_NONREPARENTING=1");
                    if (install) {
                        cmd.add("xbps-install");
                        cmd.add("-Sy");
                        cmd.add(pkg);
                    } else {
                        cmd.add("xbps-remove");
                        cmd.add("-Ry");
                        cmd.add(pkg);
                    }

                    ProcessBuilder pb = new ProcessBuilder(cmd);
                    pb.redirectErrorStream(true);
                    Process p = pb.start();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
                    String l;
                    while ((l = reader.readLine()) != null) publish(l);
                    p.waitFor();
                }
                return null;
            }
            protected void process(List<String> chunks) {
                for (String s : chunks) log(s);
            }
            protected void done() {
                refreshInstalled();
                performSearch(); // update installed states
            }
        }.execute();
    }

    private void log(String msg) {
        logArea.append(msg + "\n");
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(PackageInstallerApp::new);
    }
}