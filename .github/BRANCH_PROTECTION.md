# Branch protection & required CI checks

Apply in GitHub: **Settings → Branches → Add rule** for `main` and `develop`.

## Required status checks

Enable **Require status checks to pass before merging** and select:

| Check name | Workflow job |
|------------|----------------|
| `iOS Unit Tests (DB, middleware, backend, E2E)` | `unit-tests` |
| `iOS UI Tests (frontend)` | `ui-tests` |
| `Project integrity` | `lint-project` |

## Recommended settings

- Require a pull request before merging
- Require branches to be up to date before merging
- Do not allow bypassing the above settings (except admins if needed)

## Apply via CLI (repo admin)

```bash
gh api repos/chrsappiah-cloud/psychosocial-analytics/branches/main/protection \
  --method PUT \
  -f required_status_checks[strict]=true \
  -f required_status_checks[checks][]=unit-tests \
  -f required_status_checks[checks][]=ui-tests \
  -f required_status_checks[checks][]=lint-project \
  -f enforce_admins=true \
  -f required_pull_request_reviews[required_approving_review_count]=0 \
  -f restrictions=null
```

Note: Status check names must match the **job `name:`** fields in `.github/workflows/ci.yml` after the first workflow run on GitHub.
