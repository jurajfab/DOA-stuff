```
Basic config setup before first commit:

$ git config --global user.name "Michal Hucko"
$ git config --global user.email michal_hucko@hucko.com

# List current config
$ git config --list 

# Init git repo - creates local repository
$ git init 

Working with changes:

# Check staging area
$ git status
$ git status --ignored #show ignored files 

# Add changes to staging area  
$ git add file.py                  # add file.py 
$ git add .                        # add all file from current dir   
$ git add *.py                     # add all python files from current dir

# Create commit
$ git commit -m "Create commit using imperative commit message"
$ git commit                        # create commit with VIM prompt 

# Checking commit history
$ git log             
$ git log --oneline  
$ git log --oneline --graph
$ git log --graph --decorate
$ git log origin --oneline          # shows commits on local and remote 
$ git log -p                        # display full diff of each comment
$ git log --author "author name"    # display commits by author 
$ git log --grep="some text"        # display commits by searching for selected pattern 
$ git log -- <file>                 # display commits only for specified file 

$ git rm file.py                    # remove file from tracking and working tree
$ git rm --cached file              # odstranenie uz commitnuteho suboru z gitu, pricom subor sa nezmaze zo suboroveho systemu
$ git mv file.py new_file.py        # rename file.py 

Working with branches:


$ git branch        # list all local branches 
$ git branch -r     # list all remote branches
$ git branch -a     # list all branches

$ git switch <branch_name>          # switch to new branch 
$ git branch new_branch             # create new branch (no swithing to new branch)
$ git branch -d branch_name         # delete branch
$ git branch -d -f branch_name      # force delete branch (lost of history)

$ git checkout <branch_name>      # switch HEAD to branch_name
$ git checkout -b <branch_name>   # create new branch and switch to it

Merging branches

# To merge branch A to B make sure you are in the B branch 
$ git checkout B
$ git merge A

Working with remotes

# First genrate SSH keypair 
$ ssh-keygen -o 

# Get the public key at paste it into github settings 
$ cat ~/.ssh/id_rsa.pub

# Get synced remotes 
$ git remote 
$ git remote -v  

# Add new remote 
$ git remote add <remote_name> <remote_address>
# Set new remote (change of existing remote)
$ git remote set-url <remote_name> <remote_address>         # changes address of remote (SSH/HTTPS)

# push to remote 
$ git push <remote_name> <local_branch_name>

Joining new project

# First make sure to setup ssh key pair

# Clone the remote repository 
$ git clone <remote_repo_url>
$ git clone --progress --verbose <remote_repo_url>          # shows progress

# To track remote branch in your local branch 
$ git checkout -b <branch_name> <remote_name>/<remote_branch_name>
# e.g
$ git checkout -b test_branch origin/test_branch

# Update locally tracked branch 
$ git pull 

# Or 
$ git fetch <branch_name>                   # check if changes are on origin 
$ git merge <remote_name>/<branch_name>

Tags

$ git tag                                                     # list all tags
$ git tag <tag_name>                                          # creates tag 
$ git tag -a v1.0 -m "first version of project" 9bd9077       # creates tag and message 
$ git show <tag_name>                                         # shows info about commit from this tag 
$ git push --tags             # push tags to remote 
$ git push origin <tag_name>
$ git tag -f -a <tag_name> -m "message"         # change of tag name 
$ git tag -d <tag_name>                         # delete tag 
$ git push origin :refs/tags/<tag_name>         # delete tag on remote 
$ git push --set-upstream origin develop        # push from local to gitlab 

Going back in time

# Undo git add (remove staged changes)
$ git reset 
$ git reset <file_name>

$ git restore --staged <file>..."  # to unstage

# Undo and remove all uncommitted changes 
$ git reset --hard 
$ git reset --hard <file_name>

# Move branch to certain commit in history 
$ git log --oneline             # list commits
$ git reset --soft <commit_id>  # keep diffs in staging area
$ git reset --mixed <commit_id> # dont keep diffs in staging area
$ git reset --hard <commit_id>  # REMOVE CHANGES FOR EVER !!!!!! VERY DANGEROUS

# Move head to certain commit
$ git checkout <commit_id>      # CAREFUL its read only state
$ git switch -                  # move HEAD back to previous position
$ git switch -c <new-branch>    # create new branch from current commit
```
