# Flujo de integración

Todos los cambios destinados a `main` deben pasar primero por `staging`.

1. Crear la rama `staging` si todavía no existe.
2. Integrar los cambios en `staging`, ejecutar las comprobaciones correspondientes y publicar `staging` en el remoto.
3. Integrar en `main` la versión ya publicada de `staging` y publicar `main`.
4. Comprobar en el remoto que `main` contiene la versión de `staging` que se acaba de integrar.

Este orden también se aplica a cambios de documentación y a la primera publicación del repositorio. Si `main` todavía no existe, inicializarla desde la versión ya publicada de `staging`.
