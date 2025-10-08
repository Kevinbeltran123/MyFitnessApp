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
- **Complete RoutineBuilderScreen** with form validation and exercise picker
- **Complete RoutineDetailScreen** with full CRUD operations and rich presentation
- Enhanced exercise picker with debounced search and UX improvements
- Last-used routine tracking and session history integration
- Full routine management flow (create, list, view, edit, delete, duplicate)
- **Isar database setup** with routine repositories configured
- **Integration testing infrastructure** with service flow validation

🔧 **Recent Testing Work:**
- Widget test fixes (scrollUntilVisible scrollable parameter)
- Integration test for routine service business logic flow
- Database persistence validation attempts (blocked by Isar test environment issues)

❌ **Missing Critical Features:**
- ⭐ **Database persistence validation** - Need manual testing to confirm data survives app restarts
- No way to log body weight or measurements  
- No metrics entry UI or dashboard
- No offline data survival verification

## Your Mission
Complete the **Phase 1 fundamentals** outlined in `llm_roadmap.md`. Focus on practical, user-facing features that provide immediate value.

## Key Priorities (Updated - in order):
1. ⭐ **Database Persistence Validation** - Manually test that routines survive app restarts (Isar configured but needs verification)
2. **Integration Test Completion** - Run and validate service flow tests work correctly
3. **Metrics Tracking** - Simple weight logging and BMR display  
4. **Metrics Dashboard** - Basic charts and progress visualization
5. **Testing & Polish** - Ensure stability and user experience

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

## Next Steps (Immediate):
1. **Run Integration Test**: Execute `flutter test test/integration/routine_service_flow_test.dart` to validate business logic
2. **Manual Persistence Test**: Create a routine, close app, reopen - verify routine persists
3. **Address Isar Testing Issues**: Consider alternative testing approaches for database layer
4. **Move to Metrics**: Once persistence confirmed, implement weight tracking UI

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

**Current Priority:** Database persistence implementation - users have complete routine management but data is lost on app restart.

**Just Completed:** Complete RoutineDetailScreen with stateful flow, full CRUD operations, rich presentation, and seamless list integration (December 2024).

## 🎯 **Next Task: Database Persistence**

Complete the Isar database integration for routine persistence:
1. Ensure routines survive app restarts
2. Connect existing repositories to actual Isar database
3. Test data persistence across app sessions
4. Verify all CRUD operations work with persistent storage
5. Handle database migrations and schema updates

**Expected Duration:** 2-3 days
**Key Focus:** Move from in-memory to persistent storage