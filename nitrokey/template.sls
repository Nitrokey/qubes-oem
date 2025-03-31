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
       - libnitrokey: salt://nitrokey/libnitrokey-3.7-7.fc41.x86_64.rpm
       - nitrokey-app: salt://nitrokey/nitrokey-app-1.4.2-10.fc41.x86_64.rpm
       - hidapi: salt://nitrokey/hidapi-0.14.0-5.fc41.x86_64.rpm
     - disablerepo: '*'

nitrokey-app2:
  pkg.installed:
     - fromrepo: nitrokey-app2-offline
     - disablerepo: '*'
