locals {
  tags = merge(var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}