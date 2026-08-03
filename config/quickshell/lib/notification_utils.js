.pragma library

const getFriendlyNotifTimeString = (timestamp) => {
  if (!timestamp) return "";

  const messageTime = new Date(timestamp);
  if (isNaN(messageTime.getTime())) return "";

  const now = new Date();
  const diffMs = now.getTime() - messageTime.getTime();

  // Less than 1 minute
  if (diffMs < 60000) return "Now";

  // Same day - show relative time
  if (messageTime.toDateString() === now.toDateString()) {
    const diffMinutes = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);

    if (diffHours > 0) {
      return `${diffHours}h`;
    } else {
      return `${diffMinutes}m`;
    }
  }

  // Yesterday
  const yesterday = new Date(now.getTime() - 86400000);
  if (messageTime.toDateString() === yesterday.toDateString()) {
    return "Yesterday";
  }

  // Older dates
  return Qt.formatDateTime(messageTime, "MMM dd");
};
