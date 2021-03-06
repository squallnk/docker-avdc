# 用更优雅的方式管理硬盘中的大姐姐们(测试版)

![publish](https://github.com/VergilGao/docker-avdc/workflows/publish/badge.svg) [![GitHub license](https://img.shields.io/github/license/VergilGao/docker-avdc)](https://github.com/VergilGao/docker-avdc/blob/master/LICENSE)

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

**数据无价，请谨慎操作！**

重要的事情说三遍。

`AV_Data_Capture` 以下简称`avdc`是一款由[yoshiko2](https://github.com/yoshiko2)使用`python`编写的日本AV刮削器。

本镜像能帮助用户在nas中无需安装复杂的`python`运行时环境，可以更简单的使用`avdc`。

本镜像从仓库[AV_Data_Capture](https://github.com/yoshiko2/AV_Data_Capture)构建，版本号和源仓库的release版本号统一，初始发布版本为`3.9.1`

群晖用户可以先参考[这个 issue](https://github.com/VergilGao/docker-avdc/issues/2)使用，有什么问题尽量在此issue中提出。

* **注意，因为docker文件系统的特殊性，请仔细阅读以下操作指南后再行使用。**
* **镜像仍处于测试阶段，使用方法可能会出现较大变化。**
* **镜像作者[VergilGao](https://github.com/VergilGao)对使用此镜像导致的文件丢失、损坏均不负责。**
* **源作者[yoshiko2](https://github.com/yoshiko2)保留最终决定权和最终解释权**  
* **其他注意事项敬请参阅[源仓库的README](https://github.com/yoshiko2/AV_Data_Capture/blob/master/README.md)**

## 测试

首先你可以测试一下程序是否可用。

```sh
docker pull vergilgao/avdc
mkdir test
touch test/MIFD-046.mp4
docker run --name avdc_test -it -v ${PWD}/test:/jav/data vergilgao/avdc 
```
然后你会看到如下输出：
```sh
[*]================== AV Data Capture ===================
[*]                    Version 3.9.1
[*]======================================================
[+]Find 1 movies
[!] - 100.% [1/1] -
[!]Making Data for [./data/MIFD-046.mp4], the number is [MIFD-046]
[+]Image Downloaded! data/JAV_output/御坂りあ/MIFD-046/MIFD-046-fanart.jpg
[+]Image Cutted!     data/JAV_output/御坂りあ/MIFD-046/MIFD-046-poster.jpg
[+]Wrote!            data/JAV_output/御坂りあ/MIFD-046/MIFD-046.nfo
[*]======================================================
[+]All finished!!!
```
确认程序没有问题后把测试数据删掉就好了。顺便也删掉已经没有用了的测试容器:
```sh
sudo rm -rf test
docker rm avdc_test
```

## 自定义配置

首先，您要知晓`avdc`组织数据的方式。
`avdc`在组织数据的过程中，首先将已经刮削完成的视频文件按照`config.ini`中预设的规则硬链接到指定目录，然后再删除原文件，此后，再将原文件目录中余下的视频文件通过`mv`命令（或等同的方式）移动到`failed`目录（默认规则）。如果您对于linux系统和docker有所了解，就会知道此种数据组织方式具有潜在的问题。
所以，**请绝对不要在原仓库的`config.ini`文件作为基础配置。
我修改了一个更适合本镜像的配置文件，请仔细阅读注释后使用：
```ini
[common]
main_mode=1
; WARNING!!!
; 强烈不建议修改输出文件夹配置！
; 输出文件夹必须以data/开头，否则你的数据将会被mv到docker镜像内，如果误操作导致文件消失，请使用
; docker cp 你的docker镜像ID:/jav /你要将数据转移的目录 
; 然后在复制出来的文件里慢慢找吧！
failed_output_folder=data/failed
success_output_folder=data/JAV_output
soft_link=0
failed_move=1
auto_exit=1
transalte_to_sc=1

[proxy]
;proxytype: http or socks5 or socks5h
type=socks5
proxy=
timeout=5
retry=3

[Name_Rule]
location_rule=actor+'/'+number
naming_rule=number+'-'+title
max_title_len= 50

[update]
update_check=0

[priority]
website=javbus,javdb,fanza,xcity,mgstage,fc2,avsox,jav321,javlib,dlsite

[escape]
literals=\()/
folders=failed,JAV_output

[debug_mode]
switch=0
```
将此文件修改保存为`myconfig.ini`或者其他你喜欢的名字。

## TODO List

- [ ] 使用 s6-overlay 来增强镜像的配置
- [ ] 将`config.ini`中的配置项改为环境变量
- [ ] 监控文件系统变动让`avdc`可以在新增视频文件后自动运行
