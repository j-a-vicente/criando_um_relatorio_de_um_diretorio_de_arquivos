# Extraindo metadados dos arquivos de uma diretório com PowerShell e gravando em csv.
Em uma reunião da equipe de TI, o gerente do projeto reclama do alto volume de arquivos em um diretório do "FileServer" e solicita a equipe de análise de dado que monte um relatório para identificar quais arquivos estão com mais de 2 anos sem acesso, o top 10 dos maiores arquivos e os usuários com acesso a cada objeto "arquivos ou pasta" dentro do diretório.

## Para atender está demanda criéi um script no powershell.
Este projeto propõem uma solução simples para estar demanda, o script em PowerShell fará uma varredura no diretório indicado no script e no final monta dois arquivos "csv" com os dados:

### ListFile:
+ "Fullname", é o diretório mais o nome do arquivo ou pasta.
+ "Diretorio", local do arquivo ou pasta.
+ "Name", nome do arquivo ou pasta.
+ "CreationTime", Data e hora da criação do arquivo ou pasta.
+ "LastAccessTime", Data e hora a último acesso.
+ "LastWriteTime", Data e hora da última modificação na pasta ou arquivo.
+ "Age" total de dias que o arquivo não foi acessado.
+ "length" tamanho do arquivo em mb.
+ "Mode" se é Arquivo ou Diretório.

### ListPermission
+ "Objeto", nome do arquivo ou pasta.
+ "IdentityReference", usuário ou grupo com acesso ao objeto.
+ "FileSystemRights", Nível de acesso.
+ "AccessControlType", Especifica se um objeto AccessRule é usado para permitir ou negar acesso.
+ "IsInherited", Se o valor estiver True, o objeto herdará as permissões da pasta pai, se False, ele tem as suas próprias permissões.

