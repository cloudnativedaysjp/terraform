variable "eks_users_list" {
  default = [
    {
      userarn  = "arn:aws:iam::607167088920:user/jacopen-dev"
      username = "jacopen-dev"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/jacopen"
      username = "jacopen"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/inductor"
      username = "inductor"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/amsy810"
      username = "amsy801"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/r_takaishi"
      username = "r_takaishi"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/maktak"
      username = "maktak"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/kanata"
      username = "kanata"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/kono"
      username = "kono"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/oke-py"
      username = "oke-py"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/oshiro"
      username = "oshiro"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/ry"
      username = "ry"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::607167088920:user/riita10069"
      username = "riita10069"
      groups   = ["system:masters"]
    }
  ]
}
