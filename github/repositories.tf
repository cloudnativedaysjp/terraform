resource "github_repository" "o11y2022" {
  name        = "o11y2022"
  description = "observability2021に関わるあれこれを管理していくリポジトリ"

  visibility           = "private"
  has_issues           = true
  has_projects         = false
  has_wiki             = false
  auto_init            = true
  archive_on_destroy   = true
  vulnerability_alerts = false
  allow_merge_commit   = false
  allow_rebase_merge   = false
  allow_squash_merge   = false
  merge_commit_message        = ""
  merge_commit_title          = ""
  squash_merge_commit_message = ""
  squash_merge_commit_title   = ""
}

resource "github_repository" "cndt2021" {
  name        = "cndt2021"
  description = "CNDT2021に関わるあれこれを管理していくリポジトリ"

  visibility           = "private"
  has_issues           = true
  has_projects         = true
  has_wiki             = false
  auto_init            = false
  archive_on_destroy   = true
  vulnerability_alerts = false
  allow_merge_commit   = false
  allow_rebase_merge   = false
  allow_squash_merge   = false
  merge_commit_message        = ""
  merge_commit_title          = ""
  squash_merge_commit_message = ""
  squash_merge_commit_title   = ""
}

resource "github_repository" "website" {
  name        = "website"
  description = "Website for CloudNative Days a.k.a Dreamkast-Archives"

  visibility           = "public"
  has_issues           = true
  has_projects         = true
  has_wiki             = true
  auto_init            = false
  archive_on_destroy   = true
  vulnerability_alerts = false
  allow_merge_commit   = false
  allow_rebase_merge   = false
  allow_squash_merge   = false
  merge_commit_message        = ""
  merge_commit_title          = ""
  squash_merge_commit_message = ""
  squash_merge_commit_title   = ""
}

