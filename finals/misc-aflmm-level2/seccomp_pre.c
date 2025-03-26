#include <sys/prctl.h>
#include <seccomp.h>
#include <stdio.h>

void init() __attribute__((constructor));


void init() {
	scmp_filter_ctx ctx = seccomp_init(SCMP_ACT_KILL);

    // Add rules to allow specific syscalls
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("exit_group"), 0);
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("newfstatat"), 0);
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("read"), 1, SCMP_A0(SCMP_CMP_EQ, 0));
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("read"), 1, SCMP_A0(SCMP_CMP_EQ, 198));
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("write"), 1, SCMP_A0(SCMP_CMP_EQ, 1));
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("write"), 1, SCMP_A0(SCMP_CMP_EQ, 199));
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("shmat"), 0);
    seccomp_rule_add_exact(ctx, SCMP_ACT_ALLOW, seccomp_syscall_resolve_name("shmat"), 0);

    // Load the filter
    seccomp_load(ctx);
	seccomp_release(ctx);
}

