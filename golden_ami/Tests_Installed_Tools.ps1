Describe  'Dev Tools installation' {
    It 'Checks choco command' {
        { Get-Command "choco" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks aws command' {
        { Get-Command "aws" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks jq command' {
        { Get-Command "jq" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks aws-encryption-cli command' {
        { Get-Command "aws-encryption-cli" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks containerd command' {
        { Get-Command "containerd" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks TrendMicro Agent exists' {
        Test-Path "C:\Program Files\Trend Micro\Deep Security Agent\dsa_control.cmd" | Should -Be $env:Install_MPS
    }
    It 'Checks arp command' {
        { Get-Command "arp" -ErrorAction Stop } | Should -Not -Throw
    }
    It 'Checks netsh command' {
        { Get-Command "netsh" -ErrorAction Stop } | Should -Not -Throw
    }
}