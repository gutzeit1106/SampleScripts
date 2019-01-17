############
# �Ɛӎ��� #
############
# �{�T���v���X�N���v�g�́A�T���v���Ƃ��Ē񋟂������̂ł���A
# ���i�̎��^�p���Ŏg�p����邱�Ƃ�O��ɒ񋟂������̂ł�
# ����܂���B
#
# �{�T���v���R�[�h����т���Ɋ֘A���邠������́A�u����
# �̂܂܁v�Œ񋟂������̂ł���A���i�������̖ړI�ւ̓K����
# �Ɋւ���َ��̕ۏ؂��܂߁A�����E�َ����킸�����Ȃ�ۏ؂��t
# �������̂ł͂���܂���B
#
# �}�C�N���\�t�g�́A���q�l�ɑ΂��A�{�T���v���R�[�h���g�p�����
# ���ς��邽�߂�
# ��r���I�������̌����Ȃ�тɖ{�T���v���R�[�h���I�u�W�F�N�g
# �R�[�h�̌`����
# ��������єЕz���邽�߂̔�r���I�������̌������������܂��B
#
# �A���A���q�l�́A�i�P�j�{�T���v���R�[�h���g�ݍ��܂ꂽ���q�l��
# �\�t�g�E�F�A���i�̃}�[�P�e�B���O�̂��߂Ƀ}�C�N���\�t�g�̉��
# ���A���S�܂��́A���W��p���Ȃ����ƁA�i�Q�j�{�T���v���R�[�h��
# �g�ݍ��܂ꂽ���q�l�̃\�t�g�E�F�A���i�ɗL���Ȓ��쌠�\��������
# ���ƁA����сi�R�j�{�T���v���R�[�h�̎g�p�܂��͔Еz���琶����
# ������ ���Q�i�ٌ�m��p���܂ށj�Ɋւ��鐿���܂��͑i�ׂɂ�
# ���āA�}�C�N���\�t�g����у}�C�N���\�t�g�̎���Ǝ҂ɑ΂��⏞
# ���A���Q��^���Ȃ����Ƃɓ��ӂ�����̂Ƃ��܂��B


#�p�����[�^
$SubscriptionId = "xxxxxx" #�T�u�X�N���v�V���� ID
$VmName = "xxxxx" #���z�}�V����
$VmSize = "xxxx" #Standard_A1�Ȃ�
$VhdUri = "https://xxxx.blob.core.windows.net/vhds/xxxx.vhd" #VHD �t�@�C���p�X
$VnetName = "myvnet" #���z�l�b�g���[�N��
$AddressPrefix = "192.168.1.0/25" #�v���t�B�b�N�X
$SubnetName = "mysubnetx" #�T�u�l�b�g��
$SubnetPrefix = "192.168.1.0/27" #�v���t�B�b�N�X
$ResourceGroupName = "xxxxx" #���\�[�X�O���[�v��
$Location = "xxx" #���[�W������(japanwest�Ȃ�)
$NicName = "mynic" #NIC��
$PublicIpName = "mypip" #PublicIP��

# ���O�C���ƃT�u�X�N���v�V�����w��
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

#���z�l�b�g���[�N�̍쐬
$Vnet = New-AzureRmVirtualNetwork -Location $Location -Name $VnetName -ResourceGroupName $ResourceGroupName -AddressPrefix $AddressPrefix 
Add-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetPrefix -Name $SubnetName -VirtualNetwork $Vnet
Set-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetPrefix -Name $SubnetName -VirtualNetwork $Vnet
Set-AzureRmVirtualNetwork -VirtualNetwork $Vnet

# ���z�}�V���ݒ�̒�`
$Vm = New-AzureRmVMConfig -Name $VmName -VMSize $VmSize
$Vm = Set-AzureRmVMOSDisk -VM $Vm -VhdUri $VhdUri -Name "OSDisk" -CreateOption attach -Windows -Caching ReadWrite

# �ΏۃT�u�l�b�g���擾
$Subnet = (Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VnetName).Subnets[0]

# NIC �V�K�쐬
$Pip = New-AzureRmPublicIpAddress -Name $PublicIpName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
$Nic = New-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName -Location $Location -Subnet $Subnet -PublicIpAddress $Pip

# �쐬���� NIC ��ǉ�
$Nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NicName
$Vm = Add-AzureRmVMNetworkInterface -VM $Vm -NetworkInterface $Nic
$Vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true

# ���z�}�V���̐V�K�쐬
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $Vm -Verbose