## CONFIG

Go to config/vagrant-local-example.yml and copy it to a file named config/vagrant-local.yml
This file will be your configuration.

1. At the top, enter your own personal GitHub token.  If you do not have a token, you can generate one at your [github account settings](https://github.com/settings/tokens).  If you have one but have lost it, you can just generate a new one.
2. Make sure the machine_name is "mais"
3. Make sure your path_to_erec is an absolute url, for instance mine is `~/projects/erec-yii2`.  On a Windows machine it would be something like, `C:\Users\MyUser\Projects\erec-yii2`

## SETUP

***Note: during the composer installations, one of the packages does not set the text color flag back from red so if you see red text, it does not necessarily mean there is an error.***

- Ensure your config files are correct with the information from above
- Run `vagrant up` from your terminal in this repo's root directory
- The first time you run this vagrant machine, your terminal may ask for your user password as it adds to your host file.  If it does, enter your passward and press enter to continue
- After the vagrant box successfully provisions, you should restart the box by:
  - `vagrant halt`
  - `vagrant up`
- Once it starts up successfully again, use `vagrant ssh` to connect to your vagrant box.
- To be able to push to eRec's git repository, you need to set up your git username and email.

    ***Note: If you do not enter the same email and username from your github account, your commits will not link up to your github account.***

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your username"
```


## ~/EREC

Make sure your .env file in the erec-yii2 folder has the database named "erec".

## ~/VAGRANT

- To start up vagrant box normally:

```bash
vagrant up
```

- To gracelfully shutdown your vagrant box:

```bash
vagrant halt
```

- Too ssh into your vagrant box:

```bash
vagrant ssh
```

- To start up vagrant and do provisions again:

```bash
vagrant up --provision
```

- To destroy your vagrant machine completely to either remove it or to start from a fresh box:

***Note: destroying your vagrant box will completely delete the virtual machine an everything in it except for the contents of the directory that is shared with your host machine.  In this case, it would be the erec directroy described in your vagrant-local.yml file as path_to_erec***

```bash
vagrant destroy
```

## Troubleshooting

If your vagrant box has an issue during the provisioning, copy the errors that you can see and save them.  Try the installation again by using the `vagrant destroy` command and then `vagrant up` again.  If you continue to have issues, contact the deligated Mais vagrant box maintainer for help.
