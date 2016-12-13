function get_password(machine, login, port)
  local s = string.format("machine %s login %s port %d password ([^ ]*)\n", machine, login, port);
  local handle = io.popen("gpg2 -q --no-tty -d ~/.authinfo.gpg")
  local result = handle:read("*a")
  handle:close()
  return result:match(s)
end

workAccount = IMAP {
  server = 'imap.au.dk',
  username = 'uni\\au219464',
  password = get_password("imap.au.dk", "uni\\au219464", 993),
  ssl = "tls1"
}

privateAccount = IMAP {
  server = 'imap.gmail.com',
  username = 'peter.w.v.jorgensen@gmail.com',
  password = get_password("imap.gmail.com", "peter.w.v.jorgensen@gmail.com", 993),
  ssl = "tls1"
}

function moveAsSeen(from, to, contain)
   matches = from:contain_from(contain)
   matches:mark_seen()
   matches:move_messages(to);
end

--
-- Private account
--
privateAccount.INBOX:check_status()

moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], '@athletics.ucf.edu')

unreadPrivateSpam = privateAccount['[Gmail]/Spam']:is_unseen()
unreadPrivateSpam:mark_seen()

linkedIn = privateAccount.INBOX:contain_from('LinkedIn')
linkedIn:mark_seen()
linkedIn:move_messages(privateAccount['[Gmail]/Trash'])

paypal = privateAccount.INBOX:contain_from('PayPal')
paypal:mark_seen()
paypal:move_messages(privateAccount['[Gmail]/Trash'])

moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], 'events@fmeurope.org')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], 'IntelliSys')

--
-- Work account
--
workAccount.INBOX:check_status()

unreadWorkSpam = workAccount['Junk E-Mail']:is_unseen()
unreadWorkSpam:mark_seen()

moveAsSeen(workAccount.INBOX, workAccount['PhD/Announcements'], 'events@fmeurope.org')
moveAsSeen(workAccount.INBOX, workAccount['PhD/Announcements'], 'IntelliSys')
