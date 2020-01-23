
{% set gui_user = salt['cmd.shell']('groupmems -l -g qubes') %}
{% set usbvm_name = salt['pillar.get']('qvm:sys-usb:name', 'sys-usb') %}

# ignore failure, for example if user didn't enabled sys-usb
printf '%s\n%s\n' "$(qvm-appmenus --get-whitelist {{usbvm_name}})" "nitrokey-app.desktop" | qvm-appmenus --set-whitelist=- {{usbvm_name}} || true:
  cmd.run:
    - runas: {{gui_user}}
    - order: last
