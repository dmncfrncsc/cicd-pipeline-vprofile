import jenkins.model.Jenkins
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.attribute.PosixFilePermissions

// Runs once at startup, after JCasC has created the node. Never print the secret.
def computer = Jenkins.get().getComputer("p3-agent")
if (computer == null) {
    throw new IllegalStateException("p3-agent node not found")
}
def target = Paths.get("/var/lib/jenkins/init-secrets/agent-secret")
Files.write(target, computer.getJnlpMac().getBytes("UTF-8"))
Files.setPosixFilePermissions(target, PosixFilePermissions.fromString("rw-------"))
println "p3: agent secret file written"
