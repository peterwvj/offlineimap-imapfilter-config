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


-- The 'match_*' functions are not supported by the IMAP protocol so
-- what happens under the hood, is that the relevant parts of all the
-- messages are downloaded and matched locally. Although the 'match_*'
-- functions are not as efficient as the 'contain_*' functions (which
-- are supported by the IMAP protocol) they are not subject to
-- constraints imposed by the IMAP server. For example, some IMAP
-- servers may not support search queries such as contain_from('xyz').
function moveMatchesAsSeen(from, to, to_match)
   results = from:match_from(to_match)
   results:mark_seen()
   results:move_messages(to);
end

-- Only for testing purposes
function printFields(messages, field)
   for _,mesg in ipairs(messages) do
      mbox, uid = table.unpack(mesg)
      print(mbox[uid]:fetch_field(field))
   end
end

announcers = {'events@fmeurope.org',
              'ICCS 2017',
              'IJCR',
              'IntelliSys'}

--
-- Private account
--
privateAccount.INBOX:check_status()

allGmailFolders = {'[Gmail]/Announcements',
                   '[Gmail]/Drafts',
                   '[Gmail]/Kvitteringer',
                   '[Gmail]/PhD',
                   '[Gmail]/Sent Mail',
                   '[Gmail]/Smuk',
                   '[Gmail]/Spam',
                   '[Gmail]/Trash'}

-- Gmail tend to (sometimes) flag 'read' mails as 'unread' after they
-- have been moved. To address this annoyance, all unseen mails in the
-- Gmail folders will be marked as read. Note that 'allGmailFolders'
-- includes all the folders that are synchronised using OfflineIMAP -
-- except for the INBOX folder.
for _,g in ipairs(allGmailFolders) do
   markSeen(privateAccount[g])
end

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

moveMatchesAsSeen(workAccount.INBOX, privateAccount['Deleted Items'], 'SpringerAlerts@springeronline.com')

markSeen(workAccount['Junk E-Mail'])

for _,a in ipairs(announcers) do
   moveAsSeen(workAccount.INBOX, workAccount['PhD/Announcements'], a)
end
