#workaround for qubes-hooks ignoring disablerepo option
sed -i 's/notify-updates = 1/notify-updates = 0/' /etc/dnf/plugins/qubes-hooks.conf:
  cmd.run

nitrokey-app:
  pkg.installed:
     - sources:
       - libnitrokey: salt://nitrokey/libnitrokey-3.5-6.fc35.x86_64.rpm
       - nitrokey-app: salt://nitrokey/nitrokey-app-1.4.2-5.fc37.x86_64.rpm
       - hidapi: salt://nitrokey/hidapi-0.13.1-1.fc37.x86_64.rpm
     - disablerepo: '*'

sed -i 's/notify-updates = 0/notify-updates = 1/' /etc/dnf/plugins/qubes-hooks.conf:
  cmd.run
