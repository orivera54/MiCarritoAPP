# Implementation Plan

- [x] 1. Update database schema and create migration utilities


  - Create database migration to add volumen column to productos table
  - Implement unique index creation with conflict resolution
  - Create consolidation logic for existing duplicate products
  - _Requirements: 3.3, 3.4_



- [ ] 2. Create volume utility classes and validation
  - [ ] 2.1 Implement VolumeUtils class with formatting and parsing methods
    - Write methods to format volume display (ml to L conversion)
    - Create parsing logic for user input (L, ml, etc.)


    - Implement volume validation functions
    - _Requirements: 2.2, 2.3, 2.4_

  - [x] 2.2 Create volume-related exception classes


    - Implement InvalidVolumeException for validation errors
    - Add volume-specific error messages
    - _Requirements: 2.2_

- [x] 3. Update Producto entity and model classes


  - [ ] 3.1 Add volumen field to Producto entity
    - Add volumen property (double?, nullable)
    - Implement precioPorMl calculated property
    - Add volumenDisplay getter with formatting
    - Update equals and hashCode methods
    - _Requirements: 2.1, 2.5_



  - [ ] 3.2 Update ProductoModel with volumen support
    - Add volumen field to ProductoModel
    - Update toMap and fromMap methods

    - Implement proper serialization/deserialization
    - Update copyWith method to include volumen
    - _Requirements: 2.3, 2.4_

- [ ] 4. Implement uniqueness validation service
  - [x] 4.1 Create ProductoUniquenessService class


    - Implement isProductoUnique method with name normalization
    - Create findExistingProducto method for duplicate detection
    - Add consolidateDuplicateProductos method for data cleanup
    - _Requirements: 1.1, 1.2, 3.4_

  - [ ] 4.2 Create DuplicateProductoException class
    - Implement exception with product and almacen details
    - Add helpful error messages for users
    - Include existing product information in exception
    - _Requirements: 1.5_

- [ ] 5. Update data layer with uniqueness validation
  - [ ] 5.1 Modify ProductoLocalDataSource to include volumen
    - Update database queries to include volumen field
    - Implement uniqueness validation in create/update methods
    - Add volume-based search and filtering capabilities
    - _Requirements: 2.3, 2.7, 1.1_

  - [ ] 5.2 Update ProductoRepositoryImpl with validation logic
    - Integrate uniqueness validation before create/update operations
    - Handle DuplicateProductoException appropriately
    - Implement volume-based comparison methods
    - _Requirements: 1.2, 1.4, 2.5_

- [ ] 6. Update database helper with migration support
  - [x] 6.1 Implement database version upgrade logic


    - Add migration from current version to version with volumen
    - Handle existing data preservation during migration
    - Implement rollback capability for failed migrations
    - _Requirements: 3.1, 3.3_

  - [ ] 6.2 Add duplicate consolidation during migration
    - Identify existing duplicate products during migration
    - Implement consolidation logic preserving most recent data
    - Update references in calculadora and comparador tables
    - _Requirements: 3.4, 3.5_

- [ ] 7. Update ProductoFormScreen with volumen field and uniqueness validation
  - [ ] 7.1 Add volumen input field to form
    - Create volumen TextFormField with proper validation
    - Add unit suggestions (ml, L) with dropdown or hints
    - Implement real-time conversion and formatting
    - _Requirements: 2.1, 4.4_

  - [ ] 7.2 Implement duplicate detection in form
    - Add real-time uniqueness validation as user types
    - Show warning when potential duplicate is detected
    - Provide option to update existing product instead of creating new
    - _Requirements: 1.1, 4.2_

  - [ ] 7.3 Update form validation and error handling
    - Integrate volume validation with existing form validation
    - Handle DuplicateProductoException with user-friendly messages
    - Update save logic to handle uniqueness conflicts
    - _Requirements: 1.5, 2.2, 4.3_

- [ ] 8. Update product display widgets with volumen information
  - [ ] 8.1 Update product list and card widgets
    - Display volumen information alongside peso
    - Show precio por ml when volumen is available
    - Update product comparison displays
    - _Requirements: 2.4, 2.5_

  - [ ] 8.2 Update product detail and comparison views
    - Show both peso and volumen when available
    - Display price per unit calculations
    - Update search and filter capabilities for volumen
    - _Requirements: 2.6, 2.7_

- [ ] 9. Update business logic and use cases
  - [ ] 9.1 Update CreateProducto use case
    - Integrate uniqueness validation before creation
    - Handle volume validation and normalization
    - Update error handling for duplicate scenarios
    - _Requirements: 1.1, 1.4, 2.1_

  - [ ] 9.2 Update UpdateProducto use case
    - Validate uniqueness excluding current product ID
    - Handle volume updates and validation
    - Preserve existing data integrity during updates
    - _Requirements: 1.2, 1.3, 2.1_

- [ ] 10. Create and update unit tests for new functionality
  - [ ] 10.1 Write tests for VolumeUtils class
    - Test volume formatting and parsing methods
    - Validate conversion between different units
    - Test edge cases and invalid inputs
    - _Requirements: 2.2, 2.3, 2.4_

  - [ ] 10.2 Write tests for uniqueness validation
    - Test ProductoUniquenessService methods
    - Validate duplicate detection logic
    - Test consolidation of duplicate products
    - _Requirements: 1.1, 1.2, 3.4_

  - [ ] 10.3 Write tests for updated Producto entity
    - Test volumen field functionality
    - Validate precioPorMl calculations
    - Test entity equality with new field
    - _Requirements: 2.1, 2.5_

- [ ] 11. Create integration tests for database migration and form functionality
  - [ ] 11.1 Test database migration with existing data
    - Validate successful migration from old to new schema
    - Test duplicate consolidation during migration
    - Verify data integrity after migration
    - _Requirements: 3.1, 3.3, 3.4_

  - [ ] 11.2 Test form functionality with volumen and uniqueness
    - Test product creation with volumen field
    - Validate duplicate detection and handling
    - Test form validation and error messages
    - _Requirements: 1.5, 2.1, 4.1, 4.2_