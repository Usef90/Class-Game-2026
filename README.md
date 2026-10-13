# How to Contribute to the Game Repository


This guide will explain how to upload changes to the repository without affecting anyone else's work and potentially breaking the game.




## 1. Set Up

Before contributing ensure you have:


* Access to the GitHub. If you don't, add your GitHub username to the class google doc on Schoology under the provided section.
* [GitHub Desktop](https://desktop.github.com/) installed.
* The most recent version of \[Godot](https://godotengine.org/) installed if you are editing the game.
* A local copy of the repository on your computer.




## 2. Before beginning work

1. Clone the repository onto your own device with GitHub Desktop.
![cloning the repository](<README images/clone class game repo.png>)
2. To check for updates **fetch origin**.
![fetch origin](<README images/fetch origin.png>)
3. **Pull origin** if updates are available. 
4. Always make sure you are working on the latest version of `main`. 




## 3 Create a branch

A branch is a separate place to make changes without directly affecting the main version of the game.

Use a branch when uploading changes and never push directly to `main`


In GitHub Desktop:

1. Select **current branch** 
![current branch](<README images/changing branch.png>)
2. click **new branch**
3. Name it something describing what you are working on.
4. Create the branch from the latest `main`

Try to keep each branch focused on one task




## 4 Save and commit your changes

After editing the game or adding assets:

1. Save your files.
2. Open GitHub Desktop and review the changes.
3. Make sure you haven't included unrelated or temporary files.
4. Enter a short summary describing your changes in the **Summary** field.
5. Click **Commit to your selected branch**.
![commit to branch](<README images/commit to branch.png>)

A commit is a saved checkpoint of your work.

You can make as many commits as you need. For example, you might commit a new enemy, then commit its animations, then fix a bug.

**Committing does not upload your work to GitHub yet.** It saves the changes to your local repository




## 5 Upload your branch to GitHub

Once you've committed your changes:

1. Click **Push origin** in GitHub Desktop.
2. Your branch and its commits will be uploaded to GitHub.

You can push unfinished work whenever you want a backup. Pushing a branch does not automatically change `main` and does not require you to create a pull request immediately.




## 6. Submit a Pull Request

When your task is ready to be added to the main game:

1. Push your latest commits.
2. In GitHub Desktop, click **Create Pull Request**. This opens the PR page in your browser.
![preview pull request](<README images/view pull request.png>)
3. Check that the base branch is `main` and the compare branch is your feature branch then click create pull request.
![merge into main](<README images/merge commits into main from branch.png>)
4. GitHub will open in your browser. Give the Pull request a clear title and describe what you changed.
5. Submit the pull request.
![create pull request](<README images/create pull request.png>)

A pull request asks for your changes to be reviewed and merged into `main`.




## 7. Review and Approval

The repository requires at least one approval before changes can be merged into `main`.

- Another eligible collaborator must review your Pull request.
- The reviewer can inspect your changes and leave comments or request fixes.
- If changes are requested, make the fixes on the same branch, commit them, and push again. The existing pull request updates automatically.
- Once the required approval and other repository rules are satisfied, the pull request can be merged.

You cannot approve your own pull request to satisfy the approval requirement.




## 8. After your pull request is merged

Once your pull request has been merged:

1. Return to GitHub Desktop.
2. Switch to `main`.
3. Fetch and pull the latest changes.
4. Delete your completed feature branch if you no longer need it.
5. Create a new branch from the updated `main` for your next task.

Deleting a merged branch does not delete its changes from `main`.

## Important Rules

- **Never work directly on `main`.**
- Keep branches focused on individual tasks.
- Pull updates before starting new work.
- Commit and push regularly so your work is backed up.
- Do not overwrite another contributor's work intentionally.
- If a merge conflict occurs, resolve it carefully. Ask for help if you are unsure.
- Coordinate with other contributors before editing the same script or scene
- Do not merge your pull request until the required approval has been obtained.

The goal is to keep `main` stable while allowing everyone to work on their own features independently.




 




















