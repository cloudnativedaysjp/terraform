# resource "aws_sqs_queue" "mail_queue" {
#   name                        = "${var.prj_prefix}-mail-queue.fifo"
#   fifo_queue                  = true
#   content_based_deduplication = false
#   delay_seconds               = 0
#   message_retention_seconds   = 60
# }

resource "aws_sqs_queue" "fifo_queue" {
  name                        = "${var.prj_prefix}-fifo-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = false
  delay_seconds               = 0
  message_retention_seconds   = 60
}
