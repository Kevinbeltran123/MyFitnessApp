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
- **Advanced RoutineListScreen** with search, filtering, and metadata
- **NEW: Complete RoutineBuilderScreen** with form validation and exercise picker
- Enhanced exercise picker with debounced search and UX improvements
- Last-used routine tracking and session history integration

❌ **Missing Critical Features:**
- ⭐ **No UI to VIEW/EDIT existing routines** (users can create and list, but can't edit)
- No way to log body weight or measurements
- No persistent storage (data lost on app restart)
- No routine detail/editor screens

## Your Mission
Complete the **Phase 1 fundamentals** outlined in `llm_roadmap.md`. Focus on practical, user-facing features that provide immediate value.

## Key Priorities (Updated - in order):
1. ⭐ **RoutineDetailScreen** - Users can create and list routines but can't view/edit existing ones
2. **Persistent Storage** - Connect to Isar database so data survives app restarts  
3. **Metrics Tracking** - Simple weight logging and BMR display
4. **Database Persistence** - Complete the persistence layer for routines

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

**Current Priority:** RoutineDetailScreen implementation - users can now create and list routines but need to view/edit existing ones.

**Just Completed:** Complete RoutineBuilderScreen with focus selection, enhanced exercise picker, robust validation, and error handling (December 2024).

## 🎯 **Next Task: RoutineDetailScreen**

Create `lib/presentation/routines/routine_detail_screen.dart` with:
1. View routine details (name, description, exercises, sets/reps)
2. Edit routine functionality (reuse RoutineBuilderScreen components)
3. Delete routine with confirmation
4. Duplicate routine option
5. "Start Workout" button (connects to existing session screen)
6. Navigation from RoutineListScreen taps

**Expected Duration:** 2-3 days
**Key Navigation:** Connect from RoutineListScreen item taps