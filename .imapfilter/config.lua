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

announcers = {'events@fmeurope.org', 
              'IntelliSys'}

--
-- Private account
--
privateAccount.INBOX:check_status()

unreadPrivateSpam = privateAccount['[Gmail]/Spam']:is_unseen()
unreadPrivateSpam:mark_seen()

moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], 'LinkedIn')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], 'PayPal')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], '@athletics.ucf.edu')

for i,a in ipairs(announcers) do
   moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], a)
end

--
-- Work account
--
workAccount.INBOX:check_status()

unreadWorkSpam = workAccount['Junk E-Mail']:is_unseen()
unreadWorkSpam:mark_seen()

for i,a in ipairs(announcers) do
   moveAsSeen(workAccount.INBOX, workAccount['PhD/Announcements'], a)
end
