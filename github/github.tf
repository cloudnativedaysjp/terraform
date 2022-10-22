provider "github" {
  owner = "cloudnativedaysjp"
}

resource "github_membership" "membership_for_admin" {
  for_each = toset([
    "jacopen",
    "Fufuhu",
    "inductor",
    "jyoshise",
    "MasayaAoyama",
    "nabemasat",
    "ShotaKitazawa",
    "takaishi",
    "tsukaman"
  ])
  username = each.key
  role     = "admin"
}

resource "github_membership" "membership_for_member" {
  for_each = toset([
    "capsmalt",
    "chago0419",
    "cyberblack28",
    "Gaku-Kunimi",
    "guni1192",
    "iaoiui",
    "ito-taka",
    "kaedemalu",
    "KaseiKondo",
    "kntks",
    "maktak1995",
    "naka-teruhisa",
    "oke-py",
    "oshiro3",
    "ryojsb",
    "ryoryotaro",
    "TakumaNakagame",
    "TakumaNakagame",
    "Yoshiki0705"])
  username = each.key
  role     = "member"
}
