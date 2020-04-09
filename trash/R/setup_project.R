library(usethis)

edit_r_profile()

if (interactive()) {
  suppressMessages(require(devtools))
}

options(
  usethis.full_name = "Marcelo Araya-Salas",
  usethis.protocol  = "ssh",
  usethis.description = list(
    `Authors@R` = 'person("Marcelo", "Araya-Salas", email = "marceloa27@@gmail.com", role = c("aut", "cre"),
    comment = c(ORCID = "0000-0003-3594-619X"))',
    Version = "0.0.0.9000"
)
)


use_git_config(user.name = "maRce10", user.email = "marceloa27@gmail.com")

## check by running a git situation-report:
##   - your user.name and user.email should appear under "User"
git_sitrep()

system("git config --global core.editor rstudio")

# create new token
# browse_github_token()

# token
# 4f12b9a66f7ff87eece2c4512f780cc3efd72ab2


usethis::edit_r_environ()
# GITHUB_PAT=4f12b9a66f7ff87eece2c4512f780cc3efd72ab2

Sys.getenv("GITHUB_PAT")

## or, alternatively,
github_token()


my_cred <- git2r::cred_ssh_key(
  publickey  = "~/.ssh/id_rsa.pub",
  privatekey = "~/.ssh/id_rsa",
  # include / omit passphrase as appropriate to your situation
  passphrase = askpass::askpass()
)
use_git_credentials(credentials = my_cred)

create_from_github("maRce10/lbh_cultural_evolution", destdir = "~/Documentos/Github_projects/", protocol = "ssh")

git_credentials(protocol = "ssh")
# or
system("git@github.com:maRce10/lbh_cultural_evolution.git")

create_project(path = "~/Documentos/Github_projects/lbh_cultural_evolution/", rstudio = rstudioapi::isAvailable(), open = interactive())

proj_activate("~/Documentos/Github_projects/lbh_cultural_evolution/")

use_git()
options(usethis.full_name = "Marcelo Araya-Salas")
use_readme_rmd()

# use_data_raw()



system("git add .")
system('git commit -m  "fix README3"')
system("git push lbh_cultural_evolution master")
