output "test" {
  value = data.terraform_remote_state.networking.outputs["vpc_id"]
}