#workaround for qubes-hooks ignoring disablerepo option
sed -i 's/notify-updates = 1/notify-updates = 0/' /etc/dnf/plugins/qubes-hooks.conf:
  cmd.run
  
/var/tmp/nitrokey_offline_repo:
  file.recurse:
    - source:
      - salt://nitrokey/nitrokey_offline_repo
    - user: root
    - group: root

/etc/udev/rules.d/41-nitrokey.rules:
  file.managed:
    - source: 
       - salt://nitrokey/41-nitrokey.rules
    - user: root
    - group: root

/etc/yum.repos.d/nitrokey-app2-offline.repo:
  file.managed:
    - source:
        - salt://nitrokey/nitrokey-app2-offline.repo
    - user: root
    - group: root

/etc/yum.repos.d/nitrokey-app2.repo:
  file.managed:
    - source:
        - salt://nitrokey/nitrokey-app2.repo
    - user: root
    - group: root

/etc/yum.repos.d/nitrokey-sdk-py.repo:
  file.managed:
    - source:
        - salt://nitrokey/nitrokey-sdk-py.repo
    - user: root
    - group: root

/etc/yum.repos.d/nitrokey-3rd-party.repo:
  file.managed:
    - source:
        - salt://nitrokey/nitrokey-3rd-party.repo
    - user: root
    - group: root


nitrokey-app:
  pkg.installed:
     - sources:
       - libnitrokey: salt://nitrokey/libnitrokey-3.7-5.fc40.x86_64.rpm
       - nitrokey-app: salt://nitrokey/nitrokey-app-1.4.2-9.fc40.x86_64.rpm
       - hidapi: salt://nitrokey/hidapi-0.14.0-4.fc40.x86_64.rpm
     - disablerepo: '*'

nitrokey-app2:
  pkg.installed:
     - fromrepo: nitrokey-app2-offline
     - disablerepo: '*'

sed -i 's/notify-updates = 0/notify-updates = 1/' /etc/dnf/plugins/qubes-hooks.conf:
  cmd.run
