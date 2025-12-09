# Workflow AI

A mobile-first workflow automation application with drag-and-drop interface, similar to n8n.

## Features

- 📱 **Mobile-First Design**: Optimized for touch interactions and small screens
- 🎨 **Drag-and-Drop Interface**: Intuitive workflow creation with visual canvas
- 🔗 **Visual Connections**: Easy node connections by dragging wires
- 💾 **Local Storage**: All workflows stored locally using Hive
- 🔄 **State Management**: Built with Riverpod for reactive state
- 🎯 **Workflow Management**: Create, edit, delete, and organize workflows
- ⚡ **Workflow Execution**: Execute workflows with real-time progress tracking
- 🎛️ **Node Library**: Pre-built nodes for triggers, actions, logic, and data operations
- 🔧 **Node Configuration**: Configure nodes with custom settings
- 📊 **Execution Tracking**: Monitor workflow execution with detailed node status

## Current Status

✅ **Phase 1 Complete**: Foundation setup
- Project structure created
- Core data models (Workflow, Node, Connection, etc.)
- State management with Riverpod
- Local storage with Hive
- Basic UI theme and navigation
- Workflow list screen

✅ **Phase 2 Complete**: Core Canvas
- Scrollable/zoomable canvas with pan and zoom gestures
- Basic node rendering with visual indicators
- Node positioning system
- Grid system overlay
- Visual connection system

✅ **Phase 3 Complete**: Enhanced Drag-and-Drop
- Node library with categorized nodes
- Drag-and-drop from library to canvas
- Connection creation by dragging between nodes
- Node configuration UI
- Multiple node types (Triggers, Actions, Logic, Data)

✅ **Phase 4 Complete**: Workflow Execution Engine
- Base executor system
- Node executors (HTTP, Logic, Triggers)
- Workflow execution engine with dependency resolution
- Data flow between nodes
- Execution UI with real-time progress tracking
- Error handling and logging

🚧 **Future Enhancements**: 
- More node types and integrations
- Workflow templates
- Cloud sync
- Advanced scheduling

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android NDK 27.0.12077973 (for Android builds)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (Workflow, Node, Connection, Execution, etc.)
│   ├── services/        # Core services (Storage, etc.)
│   └── utils/           # Utility functions
├── features/
│   ├── workflows/       # Workflow-related features
│   │   ├── list/        # Workflow list screen
│   │   └── builder/     # Workflow builder with canvas
│   │       ├── canvas/  # Canvas components
│   │       ├── nodes/   # Node widgets
│   │       └── connections/ # Connection system
│   ├── nodes/           # Node library and registry
│   └── execution/       # Workflow execution engine
│       ├── executors/   # Node executors
│       └── execution_screen.dart
├── theme/               # App theme and styling
└── main.dart           # App entry point
```

## Documentation

See [PLAN.md](PLAN.md) for detailed architecture and development plan.

## Technologies

- **Flutter**: Cross-platform framework
- **Riverpod**: State management
- **Hive**: Local NoSQL database
- **Dio**: HTTP client for network requests
- **UUID**: Unique ID generation

## Supported Node Types

### Triggers
- Manual Trigger
- Schedule Trigger

### Actions
- HTTP Request (GET, POST, PUT, DELETE)
- Send Email

### Logic
- If (Conditional)
- Wait (Delay)
- Merge (Combine inputs)

### Data
- Set Variable

## Usage

1. **Create a Workflow**: Tap the + button on the workflows list
2. **Add Nodes**: Tap the + button in the builder to open the node library
3. **Connect Nodes**: Tap a green (output) port and drag to a node card
4. **Configure Nodes**: Tap any node to edit its settings
5. **Execute Workflow**: Tap the play button to run your workflow
6. **View Results**: See real-time execution progress and node results

## Contributing & Forking

This project is open for contributions and forks! We welcome developers who want to help make this a bigger, more powerful workflow automation platform.

### How to Contribute

1. **Fork the Repository**: Create your own fork to start contributing
2. **Create a Branch**: Make your changes in a feature branch
3. **Submit a Pull Request**: Share your improvements with the community

### Areas for Contribution

We're looking for contributions in these areas:

#### 🎯 High Priority
- **More Node Types**: Add integrations with popular services (Slack, Google Sheets, Twitter, etc.)
- **Workflow Templates**: Create pre-built workflow templates for common use cases
- **Cloud Sync**: Implement cloud storage and synchronization
- **Advanced Scheduling**: Add cron-based scheduling and recurring workflows
- **Webhook Support**: Enable receiving webhooks on mobile devices
- **Variable System**: Global and workflow-scoped variables

#### 🚀 Medium Priority
- **Workflow Marketplace**: Share and discover workflows created by the community
- **Collaboration Features**: Share workflows with team members
- **AI Integration**: AI-powered workflow suggestions and auto-completion
- **Analytics Dashboard**: Workflow execution analytics and insights
- **Export/Import**: Enhanced workflow sharing formats (JSON, YAML)
- **Dark Mode Polish**: Complete dark mode implementation

#### 💡 Nice to Have
- **Widget Support**: Home screen widgets for quick workflow triggers
- **Shortcuts Integration**: iOS Shortcuts and Android Tasker integration
- **Voice Commands**: Voice-activated workflow execution
- **Offline Queue**: Better offline workflow queuing and execution
- **Performance Optimization**: Further optimize canvas rendering and node execution

### Development Roadmap

#### Phase 5: Advanced Features (In Progress)
- [ ] More node types and integrations
- [ ] Workflow templates system
- [ ] Enhanced error handling
- [ ] Workflow validation

#### Phase 6: Collaboration & Sharing
- [ ] Workflow sharing
- [ ] Import/export improvements
- [ ] Workflow marketplace
- [ ] Community features

#### Phase 7: Cloud & Sync
- [ ] Cloud storage integration
- [ ] Multi-device synchronization
- [ ] Backup and restore
- [ ] Version control for workflows

#### Phase 8: AI & Intelligence
- [ ] AI-powered workflow suggestions
- [ ] Smart node recommendations
- [ ] Auto-optimization
- [ ] Natural language workflow creation

### Getting Started with Development

1. **Set up your environment**:
   ```bash
   flutter pub get
   flutter doctor
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Check code quality**:
   ```bash
   flutter analyze
   ```

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Update documentation as you add features

### Reporting Issues

Found a bug or have a feature request? Please open an issue on GitHub with:
- Clear description of the issue
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Screenshots if applicable

### Building a Bigger App

This project has the potential to become a comprehensive workflow automation platform. Here are some ideas to expand it:

- **Enterprise Features**: Team management, permissions, audit logs
- **API Platform**: REST API for programmatic workflow management
- **Plugin System**: Allow third-party developers to create custom nodes
- **Mobile Apps**: Native iOS and Android apps with platform-specific features
- **Web Dashboard**: Web interface for managing workflows from desktop
- **Integration Hub**: Connect with hundreds of services
- **Workflow Marketplace**: Monetize and share workflows
- **Analytics Platform**: Advanced analytics and reporting

Let's build something amazing together! 🚀

## License

This project is open source and available for forking and modification. Feel free to use it as a base for your own workflow automation solutions.
