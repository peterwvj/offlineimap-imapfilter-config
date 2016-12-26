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

function markSeen(folder)
   matches = folder:is_unseen()
   matches:mark_seen()
end

announcers = {'events@fmeurope.org',
              'ICCS 2017',
              'IJCR',
              'IntelliSys'}

--
-- Private account
--
privateAccount.INBOX:check_status()

markSeen(privateAccount['[Gmail]/Spam'])

moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], 'LinkedIn')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], 'Spotify')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], 'PayPal')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], '@athletics.ucf.edu')

for _,a in ipairs(announcers) do
   moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], a)
end

--
-- Work account
--
workAccount.INBOX:check_status()

markSeen(workAccount['Junk E-Mail'])

for _,a in ipairs(announcers) do
   moveAsSeen(workAccount.INBOX, workAccount['PhD/Announcements'], a)
end
