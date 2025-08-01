import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  static final PermissionHandlerService _instance = PermissionHandlerService._internal();
  factory PermissionHandlerService() => _instance;
  PermissionHandlerService._internal();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      return false;
    }
    
    return false;
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  static void showPermissionDeniedDialog(BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onOpenSettings,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOpenSettings?.call();
              openAppSettings();
            },
            child: const Text('Configuración'),
          ),
        ],
      ),
    );
  }

  static void showCameraPermissionDialog(BuildContext context) {
    showPermissionDeniedDialog(
      context,
      title: 'Permiso de cámara requerido',
      message: 'Para escanear códigos QR necesitas permitir el acceso a la cámara. '
               'Ve a Configuración > Permisos > Cámara y activa el permiso para esta aplicación.',
    );
  }

  Future<PermissionResult> handleCameraPermission(BuildContext context) async {
    final hasPermission = await checkCameraPermission();
    
    if (hasPermission) {
      return PermissionResult.granted;
    }
    
    final granted = await requestCameraPermission();
    
    if (granted) {
      return PermissionResult.granted;
    }
    
    final status = await Permission.camera.status;
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        showCameraPermissionDialog(context);
      }
      return PermissionResult.permanentlyDenied;
    }
    
    return PermissionResult.denied;
  }
}

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionAwareWidget extends StatefulWidget {
  final Widget child;
  final Permission permission;
  final Widget Function(BuildContext context)? deniedBuilder;
  final Widget Function(BuildContext context)? permanentlyDeniedBuilder;

  const PermissionAwareWidget({
    super.key,
    required this.child,
    required this.permission,
    this.deniedBuilder,
    this.permanentlyDeniedBuilder,
  });

  @override
  State<PermissionAwareWidget> createState() => _PermissionAwareWidgetState();
}

class _PermissionAwareWidgetState extends State<PermissionAwareWidget> {
  PermissionStatus? _permissionStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await widget.permission.status;
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });
    
    final status = await widget.permission.request();
    
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_permissionStatus) {
      case PermissionStatus.granted:
        return widget.child;
        
      case PermissionStatus.denied:
        return widget.deniedBuilder?.call(context) ?? 
          _DefaultPermissionDeniedWidget(
            permission: widget.permission,
            onRequestPermission: _requestPermission,
          );
          
      case PermissionStatus.permanentlyDenied:
        return widget.permanentlyDeniedBuilder?.call(context) ?? 
          _DefaultPermanentlyDeniedWidget(
            permission: widget.permission,
          );
          
      default:
        return widget.child;
    }
  }
}

class _DefaultPermissionDeniedWidget extends StatelessWidget {
  final Permission permission;
  final VoidCallback onRequestPermission;

  const _DefaultPermissionDeniedWidget({
    required this.permission,
    required this.onRequestPermission,
  });

  String get _permissionName {
    switch (permission) {
      case Permission.camera:
        return 'cámara';
      case Permission.storage:
        return 'almacenamiento';
      default:
        return 'permiso';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 80,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Permiso requerido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta función requiere acceso a $_permissionName. '
              'Por favor, concede el permiso para continuar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRequestPermission,
              icon: const Icon(Icons.security),
              label: const Text('Conceder permiso'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultPermanentlyDeniedWidget extends StatelessWidget {
  final Permission permission;

  const _DefaultPermanentlyDeniedWidget({
    required this.permission,
  });

  String get _permissionName {
    switch (permission) {
      case Permission.camera:
        return 'cámara';
      case Permission.storage:
        return 'almacenamiento';
      default:
        return 'permiso';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Permiso denegado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El permiso de $_permissionName ha sido denegado permanentemente. '
              'Ve a la configuración de la aplicación para habilitarlo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('Abrir configuración'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}