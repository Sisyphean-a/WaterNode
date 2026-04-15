abstract final class AppRoutes {
  static const dashboard = '/';
  static const tasks = '/tasks';
  static const devices = '/devices';
  static const credentials = '/credentials';
  static const auth = '/auth';

  static const workbenchRoutes = <String>[
    dashboard,
    tasks,
    devices,
    credentials,
    auth,
  ];
}
