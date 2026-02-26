



if got some problems with x11
xhost +local:
java VoidLauncher

polkit.addRule(function(action, subject) {
    if (action.id == "org.voidlauncher.run" &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});

in sudo nano /etc/polkit-1/rules.d/99-voidlauncher.rules



in sudo nano /usr/share/polkit-1/actions/org.voidlauncher.policy

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
"http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <action id="org.voidlauncher.run">
    <message>System Tools requires administrator privileges</message>
    <defaults>
      <allow_any>auth_admin</allow_any>
      <allow_inactive>auth_admin</allow_inactive>
      <allow_active>auth_admin_keep</allow_active>
    </defaults>
  </action>
</policyconfig>




