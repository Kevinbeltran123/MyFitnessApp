# 🤖 LLM Development Prompt - My Fitness Tracker

## Context
You are working on a Flutter fitness tracking app. The app has a solid foundation with rest timers and basic architecture, but needs core user features completed before moving to advanced analytics.

## Current App State
✅ **Working Features:**
- Rest timer system during workouts
- Basic routine session screen  
- Domain models for routines and metrics
- Clean architecture with Riverpod state management
- Existing exercise search and display functionality
- **NEW: Advanced RoutineListScreen** with search, filtering, and metadata
- Last-used routine tracking and session history integration

❌ **Missing Critical Features:**
- ⭐ **No UI to CREATE routines** (users can see but can't create workouts)
- No way to log body weight or measurements
- No persistent storage (data lost on app restart)
- No routine builder or editor screens

## Your Mission
Complete the **Phase 1 fundamentals** outlined in `llm_roadmap.md`. Focus on practical, user-facing features that provide immediate value.

## Key Priorities (Updated - in order):
1. ⭐ **RoutineBuilderScreen** - Users can see routines but can't create new ones
2. **Persistent Storage** - Connect to Isar database so data survives app restarts  
3. **RoutineDetailScreen** - Edit and view existing routines
4. **Metrics Tracking** - Simple weight logging and BMR display

## What NOT to Build:
- ❌ Advanced analytics or performance charts
- ❌ Complex social features or sharing
- ❌ Live workout mode with multimedia controls
- ❌ Export functionality or cloud sync
- ❌ Anything from Phase 3 of the main roadmap

## Technical Guidelines:
- Use existing architecture (Riverpod + clean architecture)
- Reuse existing widgets where possible
- Keep UI simple and Material 3 compliant
- Add basic form validation
- Include error handling for database operations
- Write unit tests for business logic

## Success Metrics:
A user should be able to:
1. Create a custom workout routine and save it
2. View their list of saved routines  
3. Start a workout from a routine (already works)
4. Log their body weight and see BMR calculation
5. Have all data persist when they restart the app

## File Reference:
- **Detailed Tasks:** `llm_roadmap.md`
- **Technical Specs:** `roadmap.md` (use for architecture reference only)
- **Architecture:** `ARCHITECTURE.md`

**Current Priority:** RoutineBuilderScreen implementation - users can now view routines but need to create new ones.

**Just Completed:** RoutineListScreen with advanced filtering, search, and last-used metadata (December 2024).

## 🎯 **Next Task: RoutineBuilderScreen**

Create `lib/presentation/routines/routine_builder_screen.dart` with:
1. Form for routine name/description
2. Exercise picker (reuse ExerciseSearchBar)
3. Sets/reps/weight configuration per exercise
4. Save validation and navigation back to list
5. Integration with existing createRoutineUseCaseProvider

**Expected Duration:** 3-4 days
**Key Navigation:** Connect from RoutineListScreen's FAB button