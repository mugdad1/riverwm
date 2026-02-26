import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.util.Map;
import javax.swing.*;

public class VoidLauncher extends JFrame {
    private JLabel statusLabel;

    public VoidLauncher() {
        setTitle("Void Launcher");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(350, 200);
        setLocationRelativeTo(null);
        setResizable(false);

        JPanel mainPanel = new JPanel(new BorderLayout(10, 10));
        mainPanel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JLabel titleLabel = new JLabel("System Tools", SwingConstants.CENTER);
        titleLabel.setFont(new Font("Monospaced", Font.BOLD, 16));
        mainPanel.add(titleLabel, BorderLayout.NORTH);

        JPanel buttonPanel = new JPanel(new GridLayout(3, 1, 0, 10));

        JButton btn1 = new JButton("Service Manager");
        btn1.setFont(new Font("Monospaced", Font.PLAIN, 12));
        btn1.setFocusPainted(false);
        btn1.addActionListener(e -> launchAppThreaded("ServiceManagerApp"));

        JButton btn2 = new JButton("Package Installer");
        btn2.setFont(new Font("Monospaced", Font.PLAIN, 12));
        btn2.setFocusPainted(false);
        btn2.addActionListener(e -> launchAppThreaded("PackageInstallerApp"));

        JButton btn3 = new JButton("FileOverwriteUI");
        btn3.setFont(new Font("Monospaced", Font.PLAIN, 12));
        btn3.setFocusPainted(false);
        btn3.addActionListener(e -> launchAppWithoutSudo("FileOverwriteUI"));

        buttonPanel.add(btn1);
        buttonPanel.add(btn2);
        buttonPanel.add(btn3);

        mainPanel.add(buttonPanel, BorderLayout.CENTER);

        statusLabel = new JLabel("Ready", SwingConstants.CENTER);
        statusLabel.setFont(new Font("Monospaced", Font.PLAIN, 10));
        statusLabel.setForeground(new Color(100, 100, 100));
        mainPanel.add(statusLabel, BorderLayout.SOUTH);

        add(mainPanel);
        setVisible(true);
    }

    private void launchAppThreaded(String appName) {
        new Thread(() -> {
            statusLabel.setText("Launching " + appName + "...");

            try {
                String currentDir = System.getProperty("user.dir");

                ProcessBuilder pb = new ProcessBuilder(
                        "env",
                        "DISPLAY=" + System.getenv("DISPLAY"),
                        "_JAVA_AWT_WM_NONREPARENTING=1",
                        "java", "-cp", currentDir, appName
                );

                Map<String, String> env = pb.environment();
                env.put("DISPLAY", System.getenv("DISPLAY"));
                env.put("_JAVA_AWT_WM_NONREPARENTING", "1");

                pb.directory(new File(currentDir));
                pb.inheritIO();

                Process process = pb.start();
                process.waitFor();
                statusLabel.setText("Ready");

            } catch (IOException | InterruptedException e) {
                SwingUtilities.invokeLater(() -> {
                    JOptionPane.showMessageDialog(
                            VoidLauncher.this,
                            "Error launching " + appName + ":\n" + e.getMessage(),
                            "Launch Failed",
                            JOptionPane.ERROR_MESSAGE
                    );
                    statusLabel.setText("Ready");
                });
            }
        }).start();
    }

    private void launchAppWithoutSudo(String appName) {
        new Thread(() -> {
            statusLabel.setText("Launching " + appName + "...");

            try {
                String currentDir = System.getProperty("user.dir");

                ProcessBuilder pb = new ProcessBuilder(
                        "env",
                        "DISPLAY=" + System.getenv("DISPLAY"),
                        "_JAVA_AWT_WM_NONREPARENTING=1",
                        "java", "-cp", currentDir, appName
                );

                Map<String, String> env = pb.environment();
                env.put("DISPLAY", System.getenv("DISPLAY"));
                env.put("_JAVA_AWT_WM_NONREPARENTING", "1");

                pb.directory(new File(currentDir));
                pb.inheritIO();

                Process process = pb.start();
                process.waitFor();
                statusLabel.setText("Ready");

            } catch (IOException | InterruptedException e) {
                SwingUtilities.invokeLater(() -> {
                    JOptionPane.showMessageDialog(
                            VoidLauncher.this,
                            "Error launching " + appName + ":\n" + e.getMessage(),
                            "Launch Failed",
                            JOptionPane.ERROR_MESSAGE
                    );
                    statusLabel.setText("Ready");
                });
            }
        }).start();
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(VoidLauncher::new);
    }
}