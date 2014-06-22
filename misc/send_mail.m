function send_mail(recipients, subject, mail_message, attachments)

% send_mail sends a mail message through Gmail

% function send_mail(subject, recipients, mail_message, attachments)

% input arguments:

% subject: A string - subject of the mail

% recipents: A cell array of strings - Email addresses of recipients

%                 eg. {'mail1@mail.com', 'mail2@mail.com'}

% mail_message: A cell array of strings - Actual body of the message A cell per line.

% attachments: A cell array of string - A cell per attachment: path to a file to attach Email.

%                      Use [] for none.

% Define these:

mail = 'frouman@gmail.com'; %Your GMail email address

password = '0945906296'; %Your GMail password

% Don't touch unless you need to change the Email supplier (currently Gmail)

setpref('Internet','E_mail',mail);

setpref('Internet','SMTP_Server','smtp.gmail.com');

setpref('Internet','SMTP_Username',mail);

setpref('Internet','SMTP_Password',password);

props = java.lang.System.getProperties;

props.setProperty('mail.smtp.auth','true');

props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');

props.setProperty('mail.smtp.socketFactory.port','465');

% Send the email

sendmail(recipients, subject, mail_message, attachments);