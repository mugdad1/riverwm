import java.awt.*;
import java.awt.event.*;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;
import javax.swing.*;

public class ServiceManagerApp extends JFrame {
    private static final String ENABLED_SERVICES_DIR = "/var/service/";
    private static final String AVAILABLE_SERVICES_DIR = "/etc/sv/";

    private JList<String> disabledList;
    private JList<String> enabledList;
    private DefaultListModel<String> disabledModel;
    private DefaultListModel<String> enabledModel;
    private JTextArea logArea;

    public ServiceManagerApp() {
        List<String> allServices = fetchServices();
        setTitle("Void Linux Service Manager");
        setSize(1000, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout(10, 10));

        disabledModel = new DefaultListModel<>();
        enabledModel = new DefaultListModel<>();

        for (String service : allServices) {
            if (isServiceEnabled(service))
                enabledModel.addElement(service);
            else
                disabledModel.addElement(service);
        }

        JPanel servicePanel = createServicePanel();
        JPanel controlPanel = createControlPanel();
        add(servicePanel, BorderLayout.CENTER);
        add(controlPanel, BorderLayout.SOUTH);
        pack();
        setLocationRelativeTo(null);
    }

    private List<String> fetchServices() {
        List<String> allServices = new ArrayList<>();
        try {
            Files.list(Paths.get(AVAILABLE_SERVICES_DIR))
                    .filter(Files::isDirectory)
                    .map(Path::getFileName)
                    .map(Path::toString)
                    .forEach(allServices::add);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return allServices;
    }

    private boolean isServiceEnabled(String service) {
        Path enabledPath = Paths.get(ENABLED_SERVICES_DIR, service);
        return Files.exists(enabledPath) && Files.isSymbolicLink(enabledPath);
    }

    private JPanel createServicePanel() {
        JPanel panel = new JPanel(new GridLayout(1, 3, 10, 10));
        panel.setBorder(BorderFactory.createTitledBorder("Manage Services"));

        disabledList = new JList<>(disabledModel);
        enabledList = new JList<>(enabledModel);
        disabledList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        enabledList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);

        JPanel disabledPanel = new JPanel(new BorderLayout());
        disabledPanel.add(new JLabel("Disabled Services"), BorderLayout.NORTH);
        disabledPanel.add(new JScrollPane(disabledList), BorderLayout.CENTER);

        JPanel enabledPanel = new JPanel(new BorderLayout());
        enabledPanel.add(new JLabel("Enabled Services"), BorderLayout.NORTH);
        enabledPanel.add(new JScrollPane(enabledList), BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new GridLayout(0, 1, 5, 5));
        JButton enableButton = new JButton("Enable >");
        JButton disableButton = new JButton("< Disable");
        enableButton.addActionListener(e -> moveSelectedService(disabledList, disabledModel, enabledModel));
        disableButton.addActionListener(e -> moveSelectedService(enabledList, enabledModel, disabledModel));
        buttonPanel.add(enableButton);
        buttonPanel.add(disableButton);

        panel.add(disabledPanel);
        panel.add(buttonPanel);
        panel.add(enabledPanel);

        return panel;
    }

    private JPanel createControlPanel() {
        JPanel controlPanel = new JPanel(new BorderLayout());
        logArea = new JTextArea(10, 50);
        logArea.setEditable(false);
        logArea.setFont(new Font("Monospaced", Font.PLAIN, 11));
        controlPanel.add(new JScrollPane(logArea), BorderLayout.CENTER);

        JButton applyButton = new JButton("Apply Service Changes");
        applyButton.addActionListener(this::applyServiceChanges);
        controlPanel.add(applyButton, BorderLayout.SOUTH);

        return controlPanel;
    }

    private void moveSelectedService(JList<String> list, DefaultListModel<String> from, DefaultListModel<String> to) {
        String val = list.getSelectedValue();
        if (val != null) {
            from.removeElement(val);
            to.addElement(val);
        }
    }

    private void applyServiceChanges(ActionEvent e) {
        logArea.setText("");
        List<String> toEnable = new ArrayList<>();
        List<String> toDisable = new ArrayList<>();

        for (int i = 0; i < enabledModel.getSize(); i++)
            if (!isServiceEnabled(enabledModel.getElementAt(i)))
                toEnable.add(enabledModel.getElementAt(i));

        for (int i = 0; i < disabledModel.getSize(); i++)
            if (isServiceEnabled(disabledModel.getElementAt(i)))
                toDisable.add(disabledModel.getElementAt(i));

        performServiceChanges(toEnable, toDisable);
    }

    private void performServiceChanges(List<String> enableServices, List<String> disableServices) {
        for (String s : disableServices) {
            logArea.append("Disabling: " + s + "\n");
            runPkexecCommand("sv", "down", s);
            runPkexecCommand("rm", "-f", ENABLED_SERVICES_DIR + s);
        }
        for (String s : enableServices) {
            logArea.append("Enabling: " + s + "\n");
            runPkexecCommand("ln", "-sf", AVAILABLE_SERVICES_DIR + s, ENABLED_SERVICES_DIR + s);
            runPkexecCommand("sv", "up", s);
        }
        logArea.append("\nDone.\n");
    }

    private void runPkexecCommand(String... cmd) {
        try {
            // Build full command with pkexec
            List<String> fullCmd = new ArrayList<>();
            fullCmd.add("pkexec");  // ask PolicyKit for privileged exec :contentReference[oaicite:3]{index=3}
            for (String c : cmd) fullCmd.add(c);

            ProcessBuilder pb = new ProcessBuilder(fullCmd);
            pb.redirectErrorStream(true);
            Process p = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));

            String line;
            while ((line = reader.readLine()) != null) {
                logArea.append("  " + line + "\n");
            }
            p.waitFor();
        } catch (IOException | InterruptedException ex) {
            logArea.append("Error: " + ex.getMessage() + "\n");
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new ServiceManagerApp().setVisible(true));
    }
}