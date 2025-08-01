import 'package:flutter/material.dart';
import 'lib/core/database/database_reset_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== SCRIPT DE RECREACIÓN DE BASE DE DATOS ===');
  
  try {
    // Verificar estructura actual
    print('\n1. Verificando estructura actual...');
    await DatabaseResetHelper.checkDatabaseStructure();
    
    // Recrear base de datos
    print('\n2. Recreando base de datos...');
    await DatabaseResetHelper.forceRecreateDatabase();
    
    // Verificar estructura después de la recreación
    print('\n3. Verificando estructura después de la recreación...');
    await DatabaseResetHelper.checkDatabaseStructure();
    
    print('\n✅ Proceso completado exitosamente');
    
  } catch (e) {
    print('\n❌ Error durante el proceso: $e');
  }
}