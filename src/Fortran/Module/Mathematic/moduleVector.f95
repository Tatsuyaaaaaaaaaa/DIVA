MODULE moduleVector
! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===                  Module specifications               ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================

! Include file
! ============
   USE moduleNorm
   
#ifndef _MODULE_VECTOR_
#define _MODULE_VECTOR_
   include 'vector.h'
   include 'ioParameter.h'
   include 'constantParameter.h'
   include 'logicalParameter.h'
#endif

! Declaration
! ===========
!  General part
!  ------------
   TYPE (vector), PRIVATE, POINTER :: workingVector => NULL()
   TYPE (vector), PRIVATE, POINTER :: secondWorkingVector => NULL()

!  Memory part
!  -----------
   INTEGER, PRIVATE, PARAMETER :: defaultIncreaseSize = 100
   INTEGER, PRIVATE, PARAMETER :: defaultStartingValue = 1
   INTEGER, PRIVATE :: increaseSize
   TYPE (vector), PRIVATE :: internalWorkingVector

! Interface
! =========
   INTERFACE vectorCreate
      MODULE PROCEDURE vectorCreateBase, vectorCreateWithDimension, vectorCreateWithDimensionAndStartingPoint
   END INTERFACE
   
! Procedures status
! =================
   PUBLIC :: printInformation, vectorDestroy, vectorSetSize, vectorGetSize, vectorSetToZero, vectorSetToValue, &
             vectorNorm1, vectorNorm2, vectorNormInfinity, vectorSqrt, vectorSum, vectorMin, vectorMax, vectorInsertValue, &
             vectorAddValue, vectorScale, vectorDot, vectorGetValue,initialise, vectorSetMemoryIncreaseSize, vectorNorm

!  General part
!  ------------
   PRIVATE :: vectorCreateBase, vectorCreateWithDimension, vectorCreateWithDimensionAndStartingPoint, &
              setWorkingVector, setSecondWorkingVector, nullify, nullifySecond

!  Memory part
!  -----------
   PRIVATE :: memorySetSize, memoryAllocateVector, memoryGetSize, memoryDestructor, &
              memoryPrintInformation, memorySetAllocatedSize, memorySetAllocated, memoryAllocateMemory, memoryGetAllocatedSize, &
              memoryStockIntermediateVector, memoryTransferIntermediateVectorToVector, memoryGetValue, memoryGetAllocationStatus, &
              memoryGetDefaultIncreaseSize, memoryVectorCreate, memoryGetPointerOnValue, memorySetStartingPoint, &
              memoryGetStartingPoint, memoryGetFinalValuePosition

!  Access part
!  -----------
   PRIVATE ::  accessVectorSetToZero, accessVectorSetToValue, accessVectorInsertValue, accessVectorAddValue
   
!  Mathematic part
!  ---------------
   PRIVATE ::  mathVectorNorm1, mathVectorNorm2, mathVectorNormInfinity, mathVectorSqrt, mathVectorSum, mathVectorMin, &
               mathVectorMax, mathVectorScale, mathVectorDot

! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===                  Module procedures                   ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================
 CONTAINS

! ============================================================
! ===            External procedure ("PUBLIC")             ===
! ============================================================

! Procedure 1 : initialisation
! ----------------------------
  SUBROUTINE initialise()

!     Body
!     - - -
      CALL vectorSetMemoryIncreaseSize(defaultIncreaseSize)

  END SUBROUTINE

! Procedure 2 : print information on the vector
! ---------------------------------------------
   SUBROUTINE printInformation(targetVector)

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memoryPrintInformation()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

   END SUBROUTINE

! Procedure 3 : destruction of the vector
! ---------------------------------------
   SUBROUTINE vectorDestroy(targetVector)

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memoryDestructor()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

   END SUBROUTINE
   
! Procedure 4 : define the size of the vector
! -------------------------------------------
  SUBROUTINE vectorSetSize(targetVector,dim)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: dim

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memorySetSize(dim)
      CALL memoryAllocateVector()
      
!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 5 : get the size of the vector
! -------------------------------------------
  FUNCTION vectorGetSize(targetVector) RESULT(dim)

!     Declaration
!     - - - - - -
      INTEGER :: dim

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      dim = memoryGetSize()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION
  
! Procedure 6 : set 0 to each entry
! ---------------------------------
  SUBROUTINE vectorSetToZero(targetVector)

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL accessVectorSetToZero()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 7 : set "value" to each entry
! ---------------------------------------
  SUBROUTINE vectorSetToValue(targetVector,val)

!     Declaration
!     - - - - - -
      REALType, INTENT(IN) :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL accessVectorSetToValue(val)

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 8 : norm1 = sum(abs(xi))
! ----------------------------------
  FUNCTION vectorNorm1(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorNorm1()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 9 : norm2 = sqrt(sum(xi^2))
! ----------------------------------
  FUNCTION vectorNorm2(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorNorm2()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 10 : norminf = maxval(abs(xi))
! ---------------------------------------
  FUNCTION vectorNormInfinity(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorNormInfinity()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 11 : sum(xi)
! ---------------------
  FUNCTION vectorSum(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorSum()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 12 : make sqrt of all values
! -------------------------------------
  SUBROUTINE vectorSqrt(targetVector)

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL mathVectorSqrt()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 13 : min value
! -----------------------
  FUNCTION vectorMin(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorMin()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 14 : min value
! -----------------------
  FUNCTION vectorMax(targetVector) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = mathVectorMax()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 15 : insert value in vector (scracth the previous one)
! ---------------------------------------------------------------
  SUBROUTINE vectorInsertValue(targetVector,position,val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: position
      REALType, INTENT(IN) :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL accessVectorInsertValue(position,val)

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 16 : add value in vector (value = old value + new value)
! -----------------------------------------------------------------
  SUBROUTINE vectorAddValue(targetVector,position,val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: position
      REALType, INTENT(IN) :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL accessVectorAddValue(position,val)

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 17 : scale the vector values
! --------------------------------------
  SUBROUTINE vectorScale(targetVector,val)

!     Declaration
!     - - - - - -
      REALType, INTENT(IN) :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL mathVectorScale(val)
      
!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END SUBROUTINE

! Procedure 18 : make the dot product of 2 vectors
! -------------------------------------------------
  FUNCTION vectorDot(targetVector1,targetVector2) RESULT(val)

!     Declaration
!     - - - - - -
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector1, targetVector2
      CALL setWorkingVector(targetVector1)
      CALL setSecondWorkingVector(targetVector2)

!     Body
!     - - -
      val = mathVectorDot()
      
!     Nullify pointer
!     - - - - - - - -
      CALL nullify()
      CALL nullifySecond()

  END FUNCTION

! Procedure 19 : get the value in the vector
! ------------------------------------------
  FUNCTION vectorGetValue(targetVector,i1) RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: i1
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      val = memoryGetValue(i1)
      
!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! Procedure 20 : define the extra size for allocate vector
! --------------------------------------------------------
  SUBROUTINE vectorSetMemoryIncreaseSize(extraSize)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: extraSize

!     Body
!     - - -
      increaseSize = extraSize
      
  END SUBROUTINE
  
! Procedure 21 : norm
! -------------------
  FUNCTION vectorNorm(targetVector,inormType) RESULT(val)

!     Declaration
!     - - - - - -
      TYPE(normType), INTENT(IN) :: inormType
      REALType :: val

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      IF ( inormType == normL1 ) THEN
         val = mathVectorNorm1()
      ELSE IF ( inormType == normL2 ) THEN
         val = mathVectorNorm2()
      ELSE IF ( inormType == normInfinity ) THEN
         val = mathVectorNormInfinity()
      ELSE
         val = mathVectorNorm2()
      ENDIF

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

  END FUNCTION

! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===          Module procedures  : general                ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================

! ============================================================
! ===            Internal procedure ("PRIVATE")            ===
! ============================================================

! Procedure 1 : setting pointer to vector
! ---------------------------------------
   SUBROUTINE setWorkingVector(targetVector)

!     Declaration
!     - - - - - -
      TYPE(vector), INTENT(IN), TARGET :: targetVector

!     Body
!     - - -
      workingVector => targetVector

   END SUBROUTINE

! Procedure 2 : make the target of the pointer null
! --------------------------------------------------
   SUBROUTINE nullify()

!     Body
!     - - -
      workingVector => NULL()

   END SUBROUTINE

! Procedure 3 : setting second pointer to vector
! ----------------------------------------------
   SUBROUTINE setSecondWorkingVector(targetVector)

!     Declaration
!     - - - - - -
      TYPE(vector), INTENT(IN), TARGET :: targetVector

!     Body
!     - - -
      secondWorkingVector => targetVector

   END SUBROUTINE

! Procedure 4 : make the target of the second pointer null
! --------------------------------------------------------
   SUBROUTINE nullifySecond()

!     Body
!     - - -
      secondWorkingVector => NULL()

   END SUBROUTINE

! Procedure 5 : create the vector (only vector pointer)
! -------------------------------
   SUBROUTINE vectorCreateBase(targetVector)

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memoryVectorCreate()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

   END SUBROUTINE

! Procedure 6 : create the vector (with dimension)
! -------------------------------
   SUBROUTINE vectorCreateWithDimension(targetVector, size)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: size

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memoryVectorCreate()
      CALL memorySetSize(size)
      CALL memoryAllocateVector()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

   END SUBROUTINE

! Procedure 6 : create the vector (with dimension and istartingValue)
! -------------------------------
   SUBROUTINE vectorCreateWithDimensionAndStartingPoint(targetVector, size, istartingValue)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: size, istartingValue

!     Pointer filling procedure
!     - - - - - - - - - - - - -
      TYPE(vector), INTENT(IN) :: targetVector
      CALL setWorkingVector(targetVector)

!     Body
!     - - -
      CALL memoryVectorCreate()
      CALL memorySetStartingPoint(istartingValue)
      CALL memorySetSize(size)
      CALL memoryAllocateVector()

!     Nullify pointer
!     - - - - - - - -
      CALL nullify()

   END SUBROUTINE

! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===          Module procedures  : memory                 ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================

! ============================================================
! ===            Internal procedure ("PRIVATE")            ===
! ============================================================


! Procedure 1 : define the size of the vector
! -------------------------------------------
   SUBROUTINE memorySetSize(ivalue)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: ivalue

!     Body
!     - - -
      workingVector%nbOfData = ivalue

   END SUBROUTINE

! Procedure 2 : define the allocated size of the vector
! ------------------------------------------------------
   SUBROUTINE memorySetAllocatedSize(ivalue)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: ivalue

!     Body
!     - - -
      workingVector%allocatedSize = ivalue

   END SUBROUTINE

! Procedure 3 : define the allocation status of the vector
! --------------------------------------------------------
   SUBROUTINE memorySetAllocated(icheck)

!     Declaration
!     - - - - - -
      LOGICAL, INTENT(IN) :: icheck

!     Body
!     - - -
      workingVector%isAllocated = icheck

   END SUBROUTINE

! Procedure 4 : allocated memory to the vector
! --------------------------------------------
   SUBROUTINE memoryAllocateVector()

!     Declaration
!     - - - - - -
      INTEGER :: newSize, istartValue

!     Body
!     - - -
      SELECT CASE (memoryGetAllocationStatus())
         CASE (.TRUE.)
            IF ( memoryGetSize() >= memoryGetAllocatedSize() ) THEN
                newSize = memoryGetSize()
                istartValue = memoryGetStartingPoint()
                CALL memoryStockIntermediateVector()
                CALL memoryDestructor()
                CALL memorySetStartingPoint(istartValue)
                CALL memorySetAllocatedSize(newSize+increaseSize)
                CALL memorySetSize(newSize)
                CALL memoryAllocateMemory()
                CALL memoryTransferIntermediateVectorToVector()
            END IF
         CASE (.FALSE.)
            CALL memoryFirstAllocateMemory()
      END SELECT

   END SUBROUTINE

! Procedure 5 : allocated memory to the vector
! ---------------------------------------------
  SUBROUTINE memoryAllocateMemory()

!     Declaration
!     - - - - - -
      INTEGER :: istart, iend
      
!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetAllocatedSize(),istart)
      
      ALLOCATE(workingVector%values(istart:iend))
      CALL memorySetAllocated(true)

  END SUBROUTINE

! Procedure 5b : allocated memory to the vector
! ---------------------------------------------
  SUBROUTINE memoryFirstAllocateMemory()

!     Body
!     - - -
      CALL memorySetAllocatedSize(ione)
      ALLOCATE(workingVector%values(memoryGetAllocatedSize()))
      CALL memorySetAllocated(true)

  END SUBROUTINE

! Procedure 6 : getting the allocated memory size
! ------------------------------------------------
  FUNCTION memoryGetAllocatedSize() RESULT(size)

!     Declaration
!     - - - - - -
      INTEGER :: size

!     Body
!     - - -
      size = workingVector%allocatedSize

   END FUNCTION

! Procedure 7 : getting the vector size
! --------------------------------------
  FUNCTION memoryGetSize() RESULT(size)

!     Declaration
!     - - - - - -
      INTEGER :: size

!     Body
!     - - -
      size = workingVector%nbOfData

   END FUNCTION

! Procedure 8 : transfer data from workingVector to secondWorkingVector
! ----------------------------------------------------------------------
  SUBROUTINE memoryStockIntermediateVector()

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart,iend
      INTEGER :: allocationSize

!     Body
!     - - -
      allocationSize = memoryGetAllocatedSize()
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(allocationSize,istart)

      internalWorkingVector%nbOfData      = allocationSize
      internalWorkingVector%allocatedSize = allocationSize
      internalWorkingVector%startValue    = istart

      IF ( allocationSize == izero ) RETURN

      ALLOCATE(internalWorkingVector%values(istart:iend))
      internalWorkingVector%isAllocated = true

      DO i1 = istart , iend
         internalWorkingVector%values(i1) = workingVector%values(i1)
      END DO

  END SUBROUTINE

! Procedure 9 : transfer data from secondWorkingVector to workingVector
! -----------------------------------------------------------------------
  SUBROUTINE memoryTransferIntermediateVectorToVector()

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart,iend
      INTEGER ::  workingSize

!     Body
!     - - -
      workingSize = internalWorkingVector%nbOfData

      IF ( workingSize == izero ) RETURN

      istart = internalWorkingVector%startValue
      iend = memoryGetFinalValuePosition(workingSize,istart)

      DO i1 = istart , iend
         workingVector%values(i1) = internalWorkingVector%values(i1)
      END DO

      internalWorkingVector%nbOfData      = izero
      internalWorkingVector%allocatedSize = izero
      internalWorkingVector%startValue    = izero
      DEALLOCATE(internalWorkingVector%values)
      internalWorkingVector%isAllocated = false

  END SUBROUTINE

! Procedure 10 : deallocation of the memory
! ------------------------------------------
  SUBROUTINE memoryDestructor()

!     Body
!     - - -
      DEALLOCATE(workingVector%values)
      workingVector%values => NULL()
      CALL memorySetSize(izero)
      CALL memorySetAllocatedSize(izero)
      CALL memorySetStartingPoint(ione)
      CALL memorySetAllocated(false)

  END SUBROUTINE

! Procedure 11 : get the value in the vector
! ------------------------------------------
  FUNCTION memoryGetValue(i1) RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: i1
      REALType :: val

!     Body
!     - - -
      val = workingVector%values(i1)

  END FUNCTION

! Procedure 12 : get the allocation status
! ----------------------------------------
  FUNCTION memoryGetAllocationStatus() RESULT(status)

!     Declaration
!     - - - - - -
      LOGICAL :: status

!     Body
!     - - -
      status = workingVector%isAllocated

  END FUNCTION

! Procedure 13 : get default increase size for vector
! ---------------------------------------------------
  FUNCTION memoryGetDefaultIncreaseSize() RESULT(dim)

!     Declaration
!     - - - - - -
      INTEGER :: dim

!     Body
!     - - -
      dim = increaseSize

  END FUNCTION

! Procedure 14 : print information on the vector
! ---------------------------------------------
   SUBROUTINE memoryPrintInformation()

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)


      WRITE(stdOutput,*) 'The size of the vector is : ', memoryGetSize()
      WRITE(stdOutput,*) '   The allocated memory is : ', memoryGetAllocatedSize()
      WRITE(stdOutput,*) '   Allocation status of the vector : ', memoryGetAllocationStatus()
      WRITE(stdOutput,*) '   First position is : ', memoryGetStartingPoint()
      WRITE(stdOutput,*) '   Last position is  : ', memoryGetFinalValuePosition(memoryGetSize(),memoryGetStartingPoint())

      IF (memoryGetAllocationStatus()) THEN
         DO i1 = istart, iend
            WRITE(stdOutput,*) 'value ',i1, ' : ', memoryGetValue(i1)
         ENDDO
      END IF

   END SUBROUTINE

! Procedure 15 : create the vector
! ---------------------------------
   SUBROUTINE memoryVectorCreate()

!     Body
!     - - -
      CALL memorySetStartingPoint(defaultStartingValue)
      CALL memorySetSize(izero)
      CALL memorySetAllocatedSize(memoryGetDefaultIncreaseSize())
      CALL memorySetAllocated(false)
      CALL memoryAllocateVector()

   END SUBROUTINE

! Procedure 16 : get the pointer on a value
! -----------------------------------------
  FUNCTION memoryGetPointerOnValue(position) RESULT(ptr)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: position
      REALType, POINTER :: ptr

!     Body
!     - - -
      ptr => workingVector%values(position)

  END FUNCTION
  
! Procedure 17 : set the starting point of the vector
! ---------------------------------------------------
  SUBROUTINE memorySetStartingPoint(ivalue)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: ivalue

!     Body
!     - - -
      workingVector%startValue = ivalue
      
  END SUBROUTINE
  
! Procedure 18 : get the starting point of the vector
! ---------------------------------------------------
  FUNCTION memoryGetStartingPoint() RESULT(ivalue)

!     Declaration
!     - - - - - -
      INTEGER :: ivalue

!     Body
!     - - -
      ivalue = workingVector%startValue

  END FUNCTION

! Procedure 19 : get the final position in the vector with respect to given dimension
! -----------------------------------------------------------------------------------
  FUNCTION memoryGetFinalValuePosition(dim, start) RESULT(ivalue)
  
!     Declaration
!     - - - - - -
      INTEGER :: dim, start, ivalue

!     Body
!     - - -
      ivalue = dim + start - 1

  END FUNCTION

! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===          Module procedures : access                  ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================

! ============================================================
! ===            Internal procedure ("PRIVATE")            ===
! ============================================================


! Procedure 1 : set 0 to each entry
! ---------------------------------
  SUBROUTINE accessVectorSetToZero()

!     Body
!     - - -
      workingVector%values = zero

  END SUBROUTINE

! Procedure 2 : set "value" to each entry
! ---------------------------------------
  SUBROUTINE accessVectorSetToValue(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType, INTENT(IN) :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)


      DO i1 = istart , iend
           workingVector%values(i1) = val
      END DO

  END SUBROUTINE

! Procedure 3 : insert value in vector (scracth the previous one)
! ---------------------------------------------------------------
  SUBROUTINE accessVectorInsertValue(position,val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: position
      REALType, INTENT(IN) :: val

!     Body
!     - - -
      IF ( position > memoryGetFinalValuePosition(memoryGetSize(),memoryGetStartingPoint()) ) RETURN

      workingVector%values(position) = val

  END SUBROUTINE

! Procedure 4 : add value in vector (value = old value + new value)
! -----------------------------------------------------------------
  SUBROUTINE accessVectorAddValue(position,val)

!     Declaration
!     - - - - - -
      INTEGER, INTENT(IN) :: position
      REALType, INTENT(IN) :: val
      REALType, POINTER :: ptr

!     Body
!     - - -
      IF ( position > memoryGetFinalValuePosition(memoryGetSize(),memoryGetStartingPoint()) ) RETURN

      ptr => memoryGetPointerOnValue(position)
      ptr = ptr + val

  END SUBROUTINE

! ============================================================
! ============================================================
! ============================================================
! ===                                                      ===
! ===                                                      ===
! ===          Module procedures : mathematic              ===
! ===                                                      ===
! ===                                                      ===
! ============================================================
! ============================================================
! ============================================================

! ============================================================
! ===            Internal procedure ("PRIVATE")            ===
! ============================================================


! Procedure 1 : norm1 = sum(abs(xi))
! ----------------------------------
  FUNCTION mathVectorNorm1() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = zero

      DO i1 = istart, iend
         val = val + abs(workingVector%values(i1))
      END DO

  END FUNCTION

! Procedure 2 : norm2 = sqrt(sum(xi^2))
! ----------------------------------
  FUNCTION mathVectorNorm2() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val
      REALType, POINTER :: ptr

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = zero

      DO i1 = istart, iend
         ptr => memoryGetPointerOnValue(i1)
         val = val + ptr * ptr
      END DO
      
      val = sqrt(val)

  END FUNCTION

! Procedure 3 : norminf = maxval(abs(xi))
! ---------------------------------------
  FUNCTION mathVectorNormInfinity() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = zero

      DO i1 = istart, iend
         val = max(val,abs(workingVector%values(i1)))
      END DO

  END FUNCTION

! Procedure 4 : sum(xi)
! ---------------------
  FUNCTION mathVectorSum() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = zero

      DO i1 = istart, iend
         val = val + workingVector%values(i1)
      END DO

  END FUNCTION

! Procedure 5 : make sqrt of all values
! -------------------------------------
  SUBROUTINE mathVectorSqrt()

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType, POINTER :: ptr

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      DO i1 = istart, iend
         ptr => memoryGetPointerOnValue(i1)
         ptr = sqrt(abs(ptr))
      END DO

  END SUBROUTINE

! Procedure 6 : min value
! -----------------------
  FUNCTION mathVectorMin() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = posInf

      DO i1 = istart, iend
         val = min(val,workingVector%values(i1))
      END DO

  END FUNCTION

! Procedure 6 : min value
! -----------------------
  FUNCTION mathVectorMax() RESULT(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)

      val = negInf

      DO i1 = istart, iend
         val = max(val,workingVector%values(i1))
      END DO

  END FUNCTION

! Procedure 7 : scale the vector values
! -------------------------------------
  SUBROUTINE mathVectorScale(val)

!     Declaration
!     - - - - - -
      INTEGER :: i1, istart, iend
      REALType :: val
      REALType, POINTER :: ptr

!     Body
!     - - -
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(memoryGetSize(),istart)


      DO i1 = istart, iend
         ptr => memoryGetPointerOnValue(i1)
         ptr = val * ptr
      END DO

  END SUBROUTINE

! Procedure 8 : make the dot product of 2 vectors
! -----------------------------------------------
  FUNCTION mathVectorDot() RESULT(val)
  
!     Declaration
!     - - - - - -
      INTEGER :: i1, size, istart, iend, istart2
      REALType :: val

!     Body
!     - - -
      size = memoryGetSize()
      istart = memoryGetStartingPoint()
      iend = memoryGetFinalValuePosition(size,istart)
      istart2 = secondWorkingVector%startValue

      val = zero

      IF ( size /= secondWorkingVector%nbOfData ) RETURN

      DO i1 = istart, iend
          val = val + secondWorkingVector%values(i1-istart+istart2) * workingVector%values(i1)
      END DO

  END FUNCTION

END MODULE moduleVector



