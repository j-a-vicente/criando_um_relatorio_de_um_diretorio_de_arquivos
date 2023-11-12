#==============================================================================================================================#
#==============================================================================================================================#
# Objetivo do script: Criar uma lista com os metadados das "pastas" diretório e arquivos "Objetos".
# Descrição: Este script faz parte de uma série de script que serão usados no processo de data discovery.
# Utiizados no processo de adequação da LGPD.
# 
# Autor: José Abelardo Vicente Filho
# Data: Abril de 2021
#==============================================================================================================================#


#==============================================================================================================================#
# VARIÁVEIS DE AMBIENTE.
#==============================================================================================================================#
#Diretório onde o script deverá fazer a varedura.
$dirStart = 'X:\ARQUIVOS_PUBLICOS\'

#Local onde o script grava os arquivos de saída.
    $dirSaida = 'C:\LOG'

#Variáveis que serão usadas no relatório.
    $Objeto   = ""
    $ContErro = 0
    $TlDr     = 0
    $TlFl     = 0
    $TGb      = 0


#Variável de data:
    $dt = Get-Date -Uformat "%Y-%m-%d %H:%M:%S"
    $dtStart = Get-Date -Uformat "%Y-%m-%d %H:%M:%S"

#Variável de data, criação dos arquivos.
    $dtFile = Get-Date -Uformat "%Y%m%d%H%M%S"

#Arquivo de log.

    #Criar o arquivo de log erro.
    New-Item "$dirSaida\Error$dtFile.log"

    #Carrega o arquivo de saída na variável.
    $LogErro = "$dirSaida\Error$dtFile.log"

#Arquivo de relatório da execução do script.

    #Criar arquivo que deverá ter o relatório.
    New-Item "$dirSaida\Relatorio$dtFile.log"

    #Carrega o arquivo de saída na variável.
    $LogRelatorio = "$dirSaida\Relatorio$dtFile.log"

#Arquivo com os Objetos que apresentaram error por falta de permissão.
#Este arquivo será usado pelo script que libera acesso aos Objetos.

    #Criar arquivo que deverá ter o relatório.
    New-Item "$dirSaida\ListaObjetosErro$dtFile.log"

    #Carrega o arquivo de saída na variável.
    $LogListObErro = "$dirSaida\ListaObjetosErro$dtFile.log"


#Grava no arquivo de erro a referência do error
    Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"
    Add-Content $LogErro -Value "Erros referente ao levantamento dos objetos"
    Add-Content $LogErro -Value "Iniciado em: $dt"

#==============================================================================================================================#
# ANÁLISE.
# Nesta etapa do código, será iniciada a análise do diretório especificado na variável "$dirStart".
#
#==============================================================================================================================#

<#####################################################################
Este comando retomará todos os arquivos e diretórios.

Legenda:
 -Fullname       = Local do arquivo mais o nome do arquivo
 -Diretorio      = Diretorio ou pasta.
 -Nome           = Nome do objeto.
 -Age            = Dias sem acesso.
 -Length         = Tamanho do objeto.
 -CreationTime   = Data da criação do objeto.
 -LastAccessTime = Data do último acesso "leitura" ao objeto.
 -LastWriteTime  = Data da última alteração ao objeto.
 -Mode           = Se o objeto é um diretório ou um arquivo.

#######################################################################>

#Aviso na tela:
Write-Output "Iniciando exploração dos objetos"

    #Extrai o volume total em giga.
    $TGb = “{0:N2}” -f ((Get-ChildItem -Path $dirStart -Recurse -Force -ErrorAction SilentlyContinue| Measure-Object Length ).sum / 1Gb)

    #Extrai os meta-dados dos objetos.
    $listFiles =  Get-ChildItem -Path $dirStart -recurse -Force -ErrorAction SilentlyContinue –ErrorVariable err | 
        Select-Object FullName,
        @{LABEL="Diretorio";Expression={if($_.Mode.Substring(0,2) -Like 'd*'){$_.FullName+"\"} elseif ($_.Mode.Substring(0,2) -Like '-a*'){$_.FullName -Replace($_.Name )  } } }  , 
        Name , CreationTime, lastAccessTime, LastWriteTime, 
        @{Name="Age";Expression={ (((Get-Date) - $_.LastWriteTime).Days) }} , 
        @{Name="Length";Expression={ if($_.Mode.Substring(0,2) -Like 'd*'){ (Get-Childitem -Path $_.FullName -Recurse | Measure-Object -Property Length -s).Sum } elseif ($_.Mode.Substring(0,2) -Like '-a*'){$_.Length} } },
        @{Name="Mode";Expression={ if($_.Mode.Substring(0,2) -Like 'd*'){"Diretorio"} elseif ($_.Mode.Substring(0,2) -Like '-a*'){"Arquivo"}   } } -ErrorAction SilentlyContinue
    

    #Grava no arquivo de Log os objetos que apresentaram erro na análise.
    Add-Content $LogErro -Value $err

        #Remove as informações de erro dos objetos.
        # Isto é preciso para montagem do relatório, esta lista será usada em outro script que fará a correção das permissões 
        # possibilitando que o script de varredura possa ser executado sem erros.
        ForEach($er in $err){
            $er = $er -replace "O acesso ao caminho '",""
            $er = $er -replace "' foi negado.",""

            $Objeto += $er
            $Objeto += "`n"        
        }

        $ContErro = $ContErro + $err.Count


#Aviso na tela:
    Write-Output "Exploração finalizada."

#Variável de data:
    $dt = Get-Date -Uformat “%Y-%m-%d %H:%M:%S"

#Grava no arquivo de erro a referência do error
    Add-Content $LogErro -Value "Finalise em: $dt"
    Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"


#Aviso na tela:
Write-Output "Criando CSV dos Objetos"

    #Exporta para o arquivo CSV os objetos analisados.
    $listFiles | Export-Csv -Path $dirSaida\listFiles$dtFile.csv #-Encoding UTF8 -NoTypeInformation


#==============================================================================================================================#
# ANÁLISE.
# Nesta etapa do código, será iniciada a análise do diretório especificado na variável "$dirStart".
#==============================================================================================================================#

<#############################################################################################################################
Depois da varredura em todos os diretórios e arquivos, agora é a vez de extrair quem pode acessar cada objeto.
Este script executa esta extração.
Com a lista de todos os objetos, será utilizada um loop para percorrer a array e buscar as permissões de acesso de cada objeto.

Legenda:
 -IdentityReference = Usuário ou grupos com acesso ao objeto.
 -FileSystemRights  = Nível de acesso ao objeto.
 -AccessControlType = Especifica se um objeto AccessRule é usado para permitir ou negar acesso.
 -IsInherited       = Se o valor estiver True, o objeto herdará as permissões do pai, se False, ele tem suas prórias permissões.

################################################################################################################################> 

#Variável de data:
    $dt = Get-Date -Uformat “%Y-%m-%d %H:%M:%S"

#Grava no arquivo de erro a referência do error
    Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"
    Add-Content $LogErro -Value "Erros referentes ao levantamento das permissões dos objetos."
    Add-Content $LogErro -Value "Iniciado em: $dt"


#Aviso na tela:
    Write-Output "Iniciando a exploração das permissões dos objetos"

    #Variáveis de ambiente.
        #Retoma o total de linhas. Observação: cada linha é um objeto, seja diretório ou arquivo.
        $ct = $listFiles.Count

        #Contador que será usado para o cálculo de porcentagem.
        $pg = 1
        
        #Contador que armazenará o progresso da análise.
        $vt = 0
#Loop: neste ponto do código, o log será iniciado
    ForEach( $lf in $listFiles){

        #Calcula o progresso da analise.
         $vt =  “{0:N2}” -f (($pg / $ct) * 100)

        #Se o objeto for um diretório, executa o primeiro comando, senão vai para o "ELSE"
        IF( $lf.Mode -eq "Diretorio"){
          $TlDr = $TlDr + 1
          #Este comando retorna todas a contas de usuários que tem acesso ao diretório que está na variável "$lf.Diretorio"
          $listPermission += (Get-Acl -Path $lf.Diretorio -ErrorAction SilentlyContinue –ErrorVariable err ).access | 
          Select-Object @{LABEL='Objeto';Expression={$lf.Diretorio}},IdentityReference,FileSystemRights,AccessControlType,IsInherited -ErrorAction SilentlyContinue
        
            #Grava no arquivo de erro os objetos que apresentaram erro na análise.
                IF ($err.Count -gt 0){
                Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"
                Add-Content $LogErro -Value $lf.Diretorio
                Add-Content $LogErro -Value $err
                Add-Content $LogErro -Value ""
                $ContErro = $ContErro + 1
                $Objeto += $lf.Diretorio
                $Objeto += "`n" 
                }
        #Caso o objeto seja um arquivo, ele executa este comando.
        }ELSE{ $TlFl = $TlFl + 1
            #Este comando retorna todas a contas de usuários que têm acesso ao diretório que está na variável "$lf.Fullname"
            $listPermission += (Get-Acl -Path $lf.Fullname -ErrorAction SilentlyContinue –ErrorVariable err ).access | 
            Select-Object @{LABEL='Objeto';Expression={$lf.Fullname}},IdentityReference,FileSystemRights,AccessControlType,IsInherited -ErrorAction SilentlyContinue

                IF ($err.Count -gt 0){
                Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"
                Add-Content $LogErro -Value $lf.Fullname
                Add-Content $LogErro -Value $err
                Add-Content $LogErro -Value ""
                $ContErro = $ContErro + 1
                $Objeto += $lf.Fullname
                $Objeto += "`n" 
                }

            }
        #Fim do SE    

            #Imprime na tela o progresso da análise.
            "Progresso: "+ $vt+"% concluido, foram analisados " + $pg +" de "+$ct

            #Contado: cada volta do Loop é somado mais um na variável.
            $pg = $pg + 1 

    }
    #Fim do Loop

#Variável de data:
    $dt = Get-Date -Uformat “%Y-%m-%d %H:%M:%S"

#Grava no arquivo de erro á referência do error
    Add-Content $LogErro -Value "Finalise em: $dt"
    Add-Content $LogErro -Value "----------------------------------------------------------------------------------------------------------------"



#Aviso na tela:
    Write-Output "Finalizado exploração das permissões dos objetos"   

    Write-Output "Criando CSV das premissões dos objetos"

#Exporta para o arquivo CSV os objetos analisados.    
    $listPermission | Export-Csv -Path $dirSaida\ListPermission$dtFile.csv #-Encoding UTF8 -NoTypeInformation

#Grava a data e hora que o script finalizou a execução.
    $dtEnd = Get-Date -Uformat “%Y-%m-%d %H:%M:%S"

#Carrega o texto no Arquivo de relatório.
#Início###################################################################################################
Add-Content $LogRelatorio -Value "************************************************************************************************************************
************************************************************************************************************************
********************** Relatório da execução do script de DATADISCOVERY para DataServer ********************************
************************************************************************************************************************
************************************************************************************************************************
**Data e hora do início da execução: $dtStart
**Data e hora do do fim da execução: $dtEnd
**Local de análise: $dirStart
**Local dos arquivos contendo os meta-dados: $dirSaida
************************************************************************************************************************
************************************************************************************************************************
**Relatório quantitativo.
************************************************************************************************************************
**Total de pastas processadas: $TlDr
**Total de arquivos processadas: $TlFl
**Total em GB de arquivos encontrados: $TGb 
************************************************************************************************************************
**Total de objetos que retornaram com erro de acesso: $ContErro

**Objetos com erro:"
Add-Content $LogRelatorio -Value $Objeto
#Fim###################################################################################################

#Carrega o texto para o arquivo lista de ojetos sem premissão.
#Que será usado pelo script de correrção de acesso.
    Add-Content $LogListObErro -Value $Objeto 