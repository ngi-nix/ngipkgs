{
  userPrefix,
  operatorsGroup,
}: ''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
  "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
  <busconfig>
    <type>system</type>

    <policy user="${userPrefix}-organize">
      <allow own="local.vula.organize"/>
      <allow
         send_destination="local.vula.discover"
         send_interface="local.vula.discover1.Listen"
         send_type="method_call"
      />
      <allow
         send_destination="local.vula.publish"
         send_interface="local.vula.publish1.Listen"
         send_type="method_call"
      />
    </policy>

    <policy user="${userPrefix}-publish">
      <allow own="local.vula.publish"/>
    </policy>

    <policy user="${userPrefix}-discover">
      <allow own="local.vula.discover"/>
      <allow
         send_destination="local.vula.organize"
         send_interface="local.vula.organize1.ProcessDescriptor"
         send_type="method_call"
      />
    </policy>

    <policy group="${operatorsGroup}">
      <allow send_destination="local.vula.organize" />
    </policy>

    <policy context="default">
      <allow
         send_destination="local.vula.organize"
         send_interface="org.freedesktop.DBus.Introspectable"
         send_type="method_call"
      />
      <allow
         send_destination="local.vula.publish"
         send_interface="org.freedesktop.DBus.Introspectable"
         send_type="method_call"
      />
      <allow
         send_destination="local.vula.discover"
         send_interface="org.freedesktop.DBus.Introspectable"
         send_type="method_call"
      />
    </policy>
  </busconfig>
''
