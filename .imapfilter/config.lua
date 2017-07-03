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

-- Only for testing purposes
function printFields(messages, field)
   for _,mesg in ipairs(messages) do
      mbox, uid = table.unpack(mesg)
      print(mbox[uid]:fetch_field(field))
   end
end


function cleanUpPrivateInbox(contain)
   moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Trash'], contain)
end


--
-- Private account
--
privateAccount.INBOX:check_status()

allGmailFolders = {'[Gmail]/Accounts',
                   '[Gmail]/Announcements',
                   '[Gmail]/Bolig',
                   '[Gmail]/Drafts',
                   '[Gmail]/Friends',
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

cleanUpPrivateInbox('LinkedIn')
cleanUpPrivateInbox('Spotify')
cleanUpPrivateInbox('PayPal')
cleanUpPrivateInbox('@athletics.ucf.edu')
cleanUpPrivateInbox('@ucfalumni.com')
cleanUpPrivateInbox('@dropboxmail.com')
cleanUpPrivateInbox('do_not_reply@info-flyingblue.com')
cleanUpPrivateInbox('@em.extendedstayamerica.com')
cleanUpPrivateInbox('info@orlandocitysc.com')
cleanUpPrivateInbox('nyhedsbrev@aarhustandcenter.dk')
cleanUpPrivateInbox('noreply@dialog.sydbank.dk')
cleanUpPrivateInbox('kundenfeedback@tns-online.com')
cleanUpPrivateInbox('noreply@mailer.atlassian.com')
cleanUpPrivateInbox('service@endomondo.com')
cleanUpPrivateInbox('noreply@mail.fitnessworld.com')
cleanUpPrivateInbox('racehall@smstiming.com')

moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Kvitteringer'], 'kvittering@midttrafik.dk')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Kvitteringer'], 'noreply@midttrafik.dk')
  
-- Call for papers and related announcements
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], 'events@fmeurope.org')
moveAsSeen(privateAccount.INBOX, privateAccount['[Gmail]/Announcements'], 'it-fmeurope-events-request@lists.uu.se')

--
-- Work account
--
workAccount.INBOX:check_status()

markSeen(workAccount['Junk E-Mail'])
