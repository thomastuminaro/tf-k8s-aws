variable "common_tags" {
  type = object({
    Project = string
    Owner = string 
  })
}