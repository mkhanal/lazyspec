function refund(capture, amount) {
  const remaining = capture.captured - capture.refunded;
  return { ok: amount <= remaining };
}
module.exports = { refund };
