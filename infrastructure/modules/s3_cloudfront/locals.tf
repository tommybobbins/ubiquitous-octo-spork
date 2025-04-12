
locals {

msk_user_credentials = {
  sasl-auth                                 = {
    replica = {
      region = "eu-west-2"
    }
  },
  aidx-validate-xml-and-publish             = {},
  aidx-repeater                             = {},
  aidx-raw-to-processed                     = {},
  aidx-processed-to-compacted               = {},
  aidx-simulation-repeater                  = {}
}

}

# msk_user_credentials = {
#   sasl-auth                                 = {},
#   aidx-validate-xml-and-publish             = {},
#   aidx-repeater                             = {},
#   aidx-raw-to-processed                     = {},
#   aidx-processed-to-compacted               = {},
#   aidx-simulation-repeater                  = {}
# }