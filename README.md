# UBICATEC Unificado

## Pasos rápidos
1) Abre esta carpeta en terminal y ejecuta:
```bash
flutter pub get
flutter create .   # genera android/ios si no existen
flutter run -d <ID_DE_TU_CEL>
```
2) Rutas: `/login` → `/intro` → `/mapar`.

### Notas de AR
- Requiere dispositivo compatible con **ARCore**.
- El AR se inicializa (cámara funcionando); para anclar modelos, edita `map_ar_screen.dart` y usa un GLB en red con `NodeType.webGLB`.
