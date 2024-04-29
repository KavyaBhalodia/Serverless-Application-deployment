variable "name" {
  type = string
}

variable "path" {
  type = map(list(string))
}

# variable "resource" {
#   type = list(string)
# }

variable "invoke_arn" {
  type = string
}

variable "function_name" {
  type = string
}