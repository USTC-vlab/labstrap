# pvestrap (Ansible playbooks)

```shell
ansible-playbook setup.yml
```

目录中含有 `ansible.cfg`，该文件会被自动读取，从而载入 `inventory.yml` 指定 hosts。

使用前需要确保 `ssh pv1` 这样的命令能够以 root 登录到 pv1，例如：

```shell
Host pv? pv??
  HsotName %h.ibugcloud.com
  User root
  #CertificateFile ~/.ssh/vlab-cert.pub

  # 非必需，但强烈推荐
  ControlPath /tmp/sshcontrol-%C
  ControlMaster auto
  ControlPersist yes
```
