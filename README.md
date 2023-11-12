Em uma reunião de equipe o coordenador da equipe de TI reclama que estamos com um alto numero de arquivos em um diretório do "FileServer" e será preciso reduzir o seu tamanho, porem não se sabe mo está a utilização dos arquivos.

Este projeto é uma solução simple, o script em PowerShell fará uma varedura no diretório indicado no script e no final monta dois arquivos vcs com os dados:
### ListFile:
+ "Fullname", é o diretório mais o nome do arquivo ou pasta.
+ "Diretorio", local do arquivo ou pasta.
+ "Name", nome do arquivos ou pasta.
+ "CreationTime", Data e hora da criação do arquivo ou pasta.
+ "LastAccessTime", Data e hora a último acesso.
+ "LastWriteTime", Data e hora da última modificação na pasta ou arquivo.
+ "Age" total de dias que o arquivo não foi acessado.
+ "length" tamanho do arquivo em mb.
+ "Mode" se é Arquivo ou Diretório.

### ListPermission
+ "Objeto", nome do arquivo ou pasta.
+ "IdentityReference",
+ "FileSystemRights",
+ "AccessControlType",
+ "IsInherited"
