# Code Review Checklist

## General PR Quality

### Metadata
- [ ] **Title**: Follows Conventional Commits format (`type(scope): description`)
- [ ] **Description**: Includes Jira ticket reference (`Refs: CTA-XXX` or `Fixes: CTA-XXX`)
- [ ] **Scope**: PR changes are focused and logically grouped
- [ ] **Breaking Changes**: Documented in PR body if present
- [ ] **Testing**: Manual testing steps or test plan included

### Documentation
- [ ] **README updates**: If feature adds new functionality
- [ ] **API docs**: If endpoints changed
- [ ] **Code comments**: Complex logic explained
- [ ] **Migration notes**: If database schema changed

---

## Code Quality

### TypeScript
- [ ] **No `any` types**: Use proper types or `unknown`
- [ ] **Strict null checks**: Handle `null` and `undefined` explicitly
- [ ] **Interface usage**: Shared types in separate files
- [ ] **Generic types**: Used appropriately for reusability

### React/React Native
- [ ] **Hooks dependencies**: `useEffect`/`useCallback`/`useMemo` deps arrays correct
- [ ] **Key props**: Unique and stable keys in lists
- [ ] **Component size**: Components under 300 lines
- [ ] **State management**: Local state vs global state appropriate
- [ ] **Performance**: No unnecessary re-renders (use React DevTools)

### General Code
- [ ] **Naming**: Variables/functions have clear, descriptive names
- [ ] **Function length**: Functions under 50 lines
- [ ] **Nesting**: Max 3 levels of nesting
- [ ] **Error handling**: Try-catch around risky operations
- [ ] **Logging**: Debug logs removed, audit logs present where needed
- [ ] **TODOs**: Justified or removed

---

## Architecture Alignment

### Offline-First Patterns (if applicable)
- [ ] **UUID generation**: Client-side UUIDs for new entities
- [ ] **Local-first**: Operations persist to SQLite before API call
- [ ] **Sync conflicts**: Conflict resolution logic present
- [ ] **Queue-based sync**: Operations queued for upload when offline

### API Integration
- [ ] **API contract**: Changes match `api-contract.yaml`
- [ ] **Error handling**: HTTP error codes handled properly
- [ ] **Retry logic**: Transient failures retried with exponential backoff
- [ ] **Timeout handling**: Requests have reasonable timeouts

### Database
- [ ] **Schema changes**: `vct_anywhere_db_schema.dbml` updated
- [ ] **Migrations**: Database migration script included if schema changed
- [ ] **Indexing**: Queries use appropriate indexes
- [ ] **Transactions**: Multi-step operations wrapped in transactions

---

## Project Conventions

### File Structure
- [ ] **Location**: Files in correct directory (components/, screens/, services/, etc.)
- [ ] **Imports**: Absolute imports using @shared, @features, etc.
- [ ] **Exports**: Named exports for non-components, default for components

### Git Conventions
- [ ] **Branch name**: Follows `<parentBranch>_CTA-XXX_<description>` format
- [ ] **Commit messages**: Follow Conventional Commits
- [ ] **Commit size**: Logical commits, not "WIP" or "fix typo"

### CI/CD
- [ ] **All checks pass**: Green checkmark on PR
- [ ] **No linting errors**: ESLint/TSLint clean
- [ ] **Tests pass**: Unit/integration tests green
- [ ] **Build succeeds**: No compilation errors

---

## Common Issues to Flag

### Anti-Patterns
- ❌ **DatabaseService in render**: Should use `useDatabaseService()` hook
- ❌ **Inline styles**: Use StyleSheet.create()
- ❌ **Magic numbers**: Use named constants
- ❌ **Callback hell**: Use async/await instead of nested callbacks
- ❌ **Direct state mutation**: Use immutable updates

### Code Smells
- ⚠️ **Long parameter lists**: More than 4 parameters, use config object
- ⚠️ **Duplicated code**: Extract to shared function
- ⚠️ **Feature envy**: Class/function accessing other's data too much
- ⚠️ **Dead code**: Unused imports, functions, variables

### Missing Considerations
- 🔍 **Security**: Input validation, SQL injection prevention, XSS risks
- 🔍 **Performance**: Database query optimization, image sizes, bundle size
- 🔍 **Accessibility**: Screen reader support, keyboard navigation
- 🔍 **Internationalization**: Hard-coded strings (should use i18n)

---

## Review Severity Levels

### 🔴 Critical (Blocking)
**Must be fixed before merge**
- Security vulnerabilities
- Data loss risks
- Breaking changes without migration
- Crashes or critical bugs
- Violates core architecture principles

### 🟡 Major (Should fix)
**Strongly recommended to address**
- Performance issues
- Poor error handling
- Code quality violations
- Missing tests for critical paths
- Inconsistent with project conventions

### 🔵 Minor (Nice to have)
**Suggestions for improvement**
- Code style nitpicks
- Naming improvements
- Comment additions
- Refactoring opportunities
- Optimization suggestions

---

## Giving Good Feedback

### ✅ Do:
- Be specific: "Line 45: Missing null check for user.email"
- Explain why: "This could throw TypeError if user is undefined"
- Suggest fix: "Add `if (!user?.email) return;`"
- Acknowledge good work: "Great use of memoization here!"

### ❌ Don't:
- Be vague: "Code looks weird"
- Just criticize: "This is wrong"
- Assume intent: "You don't understand TypeScript"
- Ignore positives: Only list problems

---

## Resources

- [CONTRIBUTING.md](../../../CONTRIBUTING.md) - Project contribution guidelines
- [Conventional Commits](https://www.conventionalcommits.org/)
- [TypeScript Best Practices](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)
- [React Hooks Rules](https://react.dev/reference/rules/rules-of-hooks)
