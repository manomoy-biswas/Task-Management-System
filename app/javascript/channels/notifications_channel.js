import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    console.log(data.content)
    $("#unread-count,#unread-count1").text("(" + data.count + ")")
    $("#notifications,#notifications1").prepend(data.content)
  }
});
